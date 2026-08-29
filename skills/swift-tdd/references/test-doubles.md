# When to Fake a Dependency

Swift has no `jest.mock`. There is no runtime monkey-patching, so a test double is
just **another conformance to a protocol you already own**. That constraint is a
feature: if something is hard to fake, the design is telling you the seam is wrong.

## Fake at system boundaries only

Fake these:

- Network clients and external APIs
- Persistence you don't want to hit (`URLSession`, CloudKit, a live database)
- Time, randomness, and UUIDs
- The file system, the keychain, the location manager
- Anything requiring device capabilities or entitlements

Don't fake these:

- Your own value types — construct real ones
- Internal collaborators
- Anything cheap and deterministic to build

A `struct` with no side effects never needs a double. Build the real thing.

## Designing for substitution

### 1. Inject dependencies through protocols

```swift
// GOOD: the seam is explicit and substitutable
protocol PaymentGateway: Sendable {
    func charge(_ amount: Decimal) async throws -> Receipt
}

func processPayment(for order: Order, using gateway: some PaymentGateway) async throws -> Receipt {
    try await gateway.charge(order.total)
}
```

```swift
// BAD: the dependency is welded in — nothing to substitute
func processPayment(for order: Order) async throws -> Receipt {
    let client = StripeClient(apiKey: ProcessInfo.processInfo.environment["STRIPE_KEY"]!)
    return try await client.charge(order.total)
}
```

The fake is then ordinary Swift:

```swift
struct StubGateway: PaymentGateway {
    var result: Result<Receipt, PaymentError> = .success(.sample)
    func charge(_ amount: Decimal) async throws -> Receipt { try result.get() }
}
```

Note the concrete `PaymentError` rather than `any Error`: `Result<Receipt, any Error>`
is not `Sendable`, so it would not satisfy the protocol's `Sendable` requirement
under Swift 6 strict concurrency.

### 2. Prefer specific operations over one generic entry point

```swift
// GOOD: each operation is independently stubbable
protocol UserAPI: Sendable {
    func user(id: User.ID) async throws -> User
    func orders(for id: User.ID) async throws -> [Order]
    func createOrder(_ draft: OrderDraft) async throws -> Order
}
```

```swift
// BAD: stubbing requires branching on the endpoint inside the fake
protocol HTTPClient: Sendable {
    func send(_ request: URLRequest) async throws -> Data
}
```

With the generic version every fake grows a `switch` over paths, and decoding
errors surface as test-setup bugs rather than failures.

### 3. Closure-based doubles for one-method seams

When a protocol would carry a single requirement, a struct of closures is lighter
and configurable inline:

```swift
struct Clock: Sendable {
    var now: @Sendable () -> Date
    static let live = Clock { Date() }
    static func fixed(_ date: Date) -> Clock { Clock { date } }
}

@Test("a token minted now is still valid")
func freshTokenIsValid() {
    let session = Session(clock: .fixed(.testReference))
    #expect(session.mintToken().isValid(at: .testReference))
}
```

This is how you kill `Date()`, `UUID()`, and `Task.sleep` non-determinism —
inject them rather than tolerating them.

### 4. Fake the transport, not your own layer

To exercise real networking code without a network, substitute `URLProtocol`
instead of wrapping your client in another protocol:

```swift
final class StubURLProtocol: URLProtocol {
    nonisolated(unsafe) static var handler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for r: URLRequest) -> URLRequest { r }
    override func startLoading() {
        guard let handler = Self.handler else { return }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    override func stopLoading() {}
}
```

Your decoding, retry, and error-mapping logic then runs for real — which is
usually the part actually worth testing.

## Concurrency notes

- Make doubles `Sendable`. A fake that can't cross an isolation boundary forces
  `@MainActor` onto tests that shouldn't need it.
- For mutable recording, prefer an `actor` double over `nonisolated(unsafe)` state.
- But recording call counts is usually the implementation-coupled anti-pattern in
  disguise — prefer asserting the outcome the caller can observe.
