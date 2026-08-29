# Good and Bad Tests in Swift

Examples use [Swift Testing](https://developer.apple.com/documentation/testing).
XCTest equivalents are noted where the shape differs.

## Good tests

**Integration-style**: test through real interfaces, not fakes of internal parts.

```swift
// GOOD: tests observable behavior
@Test("user can check out with a valid cart")
func checkoutWithValidCart() async throws {
    var cart = Cart()
    cart.add(.sampleProduct)

    let result = try await checkout(cart, using: .validCard)

    #expect(result.status == .confirmed)
}
```

Characteristics:

- Tests behavior callers care about
- Uses the public API only
- Survives internal refactors
- Describes WHAT, not HOW
- One logical assertion per test

Use `#require` when a later line would crash on failure — it throws and stops the
test, where `#expect` records and continues:

```swift
@Test("order confirmation carries a receipt")
func confirmationHasReceipt() async throws {
    let result = try await checkout(.sampleCart, using: .validCard)

    let receipt = try #require(result.receipt)   // stop here if nil
    #expect(receipt.total == 15.00)
}
```

## Bad tests

**Implementation-detail tests**: coupled to internal structure.

```swift
// BAD: tests implementation details
@Test func checkoutCallsPaymentProcess() async throws {
    let spy = PaymentSpy()
    _ = try await checkout(.sampleCart, using: spy)

    #expect(spy.processCallCount == 1)
    #expect(spy.lastAmount == 15.00)
}
```

Red flags:

- Faking internal collaborators
- Testing `private` methods, or reaching for `internal` ones via `@testable`
- Asserting on call counts or call order
- Test breaks on refactor with no behavior change
- Test name describes HOW, not WHAT

```swift
// BAD: bypasses the interface to verify
@Test func createUserWritesToStore() async throws {
    _ = try await store.createUser(name: "Alice")

    let rows = try await database.execute("SELECT * FROM users WHERE name = ?", ["Alice"])
    #expect(!rows.isEmpty)
}

// GOOD: verifies through the interface
@Test func createdUserIsRetrievable() async throws {
    let created = try await store.createUser(name: "Alice")

    let retrieved = try await store.user(id: created.id)
    #expect(retrieved.name == "Alice")
}
```

**Tautological tests**: the expected value restates the implementation, so the
test passes by construction.

```swift
// BAD: expected value is recomputed the way the code computes it
@Test func totalSumsLineItems() {
    let items = [LineItem(price: 10), LineItem(price: 5)]
    let expected = items.reduce(0) { $0 + $1.price }

    #expect(calculateTotal(items) == expected)
}

// GOOD: expected value is an independent, known literal
@Test func totalSumsLineItems() {
    #expect(calculateTotal([LineItem(price: 10), LineItem(price: 5)]) == 15)
}
```

## Swift-specific shapes

**Parameterized tests** replace hand-rolled loops, and report each case separately:

```swift
@Test("VAT is applied per region", arguments: [
    (Region.uk, 100.0, 120.0),
    (Region.ie, 100.0, 123.0),
    (Region.us, 100.0, 100.0),
])
func vatPerRegion(region: Region, net: Double, gross: Double) {
    #expect(applyVAT(net, in: region) == gross)
}
```

**Expected failures** — assert the error, never just that *something* threw:

```swift
@Test("checkout rejects an expired card")
func expiredCardRejected() async {
    await #expect(throws: CheckoutError.cardExpired) {
        try await checkout(.sampleCart, using: .expiredCard)
    }
}
```

**Main-actor code** — annotate the test rather than hopping inside it:

```swift
@MainActor
@Test("selecting a row updates the detail view model")
func selectionUpdatesDetail() {
    let model = ListViewModel(items: .sample)
    model.select(id: .first)
    #expect(model.detail?.id == .first)
}
```

**Async work with no return value** — use `confirmation`, never `Task.sleep`:

```swift
@Test("sync emits a progress update per batch")
func syncEmitsProgress() async throws {
    await confirmation("progress fired", expectedCount: 3) { fired in
        let service = SyncService(onProgress: { _ in fired() })
        try? await service.sync(batches: 3)
    }
}
```

**Traits** carry intent that comments can't enforce:

```swift
@Test(.tags(.integration), .timeLimit(.minutes(1)))
func fullSyncAgainstStagingBackend() async throws { /* ... */ }

@Test(.disabled("flaky until FB1234 lands"))
func knownFlakyCase() {}
```

Prefer `.disabled(_:)` over commenting a test out — it stays compiled, so it can't
silently rot.
