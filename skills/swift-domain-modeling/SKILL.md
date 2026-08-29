---
name: swift-domain-modeling
description: Build and sharpen a Swift project's domain model using the type system — value types, enums, raw-value wrappers, and phantom types — plus CONTEXT.md glossaries and ADRs. Use when discussing codebase terminology, naming types, deciding what should be an enum, or recording an architectural decision.
---

# Domain Modeling in Swift

Actively build and sharpen the domain model as you design. This is the *active*
discipline — challenging terms, inventing edge cases, and writing decisions down
the moment they crystallise. Merely reading a glossary for vocabulary is a habit,
not this skill.

Swift's type system is unusually good at holding a domain model. The payoff for
getting the vocabulary right is not just readable code: it's states the compiler
refuses to let you represent.

## Make illegal states unrepresentable

This is the highest-leverage move in Swift domain modeling. Before writing a
type, ask what combinations of its fields are nonsense — then choose a shape that
can't express them.

```swift
// Weak: 8 representable combinations, 5 of them nonsense.
struct LoadState {
    var isLoading: Bool
    var value: Order?
    var error: Error?
}
```

```swift
// Strong: exactly 4 states, all meaningful.
enum LoadState {
    case idle
    case loading
    case loaded(Order)
    case failed(any Error)
}
```

The tell that you need this: code full of `if let value, !isLoading` guards, or a
comment explaining which fields are valid together. Every such guard is a state
the type should have ruled out.

## Give domain concepts their own types

A `String` that means one thing and a `String` that means another are the same
type to the compiler, and swapping them compiles.

```swift
// Primitive obsession: these are trivially swappable at a call site.
func transfer(from: String, to: String, amount: Double)
```

```swift
// Each concept is its own type; the wrong order stops compiling.
struct AccountID: Hashable, Codable, RawRepresentable { let rawValue: String }
struct Money: Hashable, Codable { let minorUnits: Int; let currency: Currency }

func transfer(from: AccountID, to: AccountID, amount: Money)
```

Reach for this when an identifier, a unit, or a code (currency, locale, SKU) is
being passed as `String`, `Int`, or `Double`. `Money` as `Double` is the classic
one — floating point cannot represent currency, so the domain type fixes a real
bug and not just a naming problem.

Swift makes these nearly free: `RawRepresentable` + `Hashable` + `Codable` gives
a wrapper that serialises identically to the primitive it replaces, so adopting
one is not a wire-format change.

## Let names in code match names in the glossary

If the glossary says **Subscriber** and the code says `User`, one of them is
wrong. Rename rather than tolerate the drift — a domain model that disagrees with
its implementation stops being consulted, and once nobody consults it, it rots.

Swift API design guidelines apply on top of the domain vocabulary, not instead of
it: `Order.cancel()` not `Order.doCancellation()`, and `orders(for:)` not
`getOrders(userID:)`.

## Where the model lives

```
/
├── CONTEXT.md              ← the glossary, and nothing else
├── docs/adr/
│   ├── 0001-offline-first-sync.md
│   └── 0002-swiftdata-over-core-data.md
└── Sources/
```

For a multi-module SPM or Tuist project, each module that owns a bounded context
gets its own `CONTEXT.md` next to its `Sources/`, with system-wide decisions
staying in the root `docs/adr/`.

Create files lazily — only when there's something to write.

## During the session

**Challenge against the glossary.** When a term conflicts with `CONTEXT.md`, say
so immediately: "the glossary defines cancellation as X, but you seem to mean Y."

**Sharpen fuzzy language.** "You're saying *account* — do you mean `Customer` or
`Account`? Those are different types."

**Stress-test with scenarios.** Invent edge cases that force precision about
where one concept ends and another begins. "What happens to a Subscription when
the payment method expires mid-period?" — the answer usually reveals a missing
enum case.

**Cross-reference with code.** When the user states how something works, check
whether the types agree. "Your `Order` has a single `status`, but you just
described partial cancellation. Which is right?"

**Update `CONTEXT.md` inline** the moment a term is resolved — don't batch them.
Keep it free of implementation detail. It's a glossary, not a spec, not a scratch
pad.

## Offer ADRs sparingly

Only when all three hold:

1. **Hard to reverse** — the cost of changing your mind later is real
2. **Surprising without context** — a future reader will ask "why this way?"
3. **A genuine trade-off** — there were real alternatives and you picked one

Missing any of the three, skip it.

On Apple platforms the decisions that reliably earn an ADR are the ones that are
expensive to walk back once shipped: **SwiftData vs Core Data vs GRDB**, the
**persistence migration strategy**, **UIKit vs SwiftUI** for a surface,
**minimum deployment target**, **module boundaries**, and **anything that
changes an on-disk format or a wire contract users have already written to.**

---

*Adapted for Swift from [`mattpocock/skills`](https://github.com/mattpocock/skills)
(`engineering/domain-modeling`), MIT © Matt Pocock. The glossary/ADR discipline is his;
the Swift type-system material is new. Full license in [NOTICE.md](NOTICE.md).*
