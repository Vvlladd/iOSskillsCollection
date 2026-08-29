---
name: swift-tdd
description: Test-driven development for Swift using Swift Testing or XCTest. Use when building features or fixing bugs test-first, when the user mentions red-green-refactor, when deciding what to test in an iOS/macOS codebase, or when tests keep breaking during refactors without behavior changing.
---

# Test-Driven Development in Swift

TDD is the red → green loop. This skill is the reference that makes that loop
produce tests worth keeping: what a good test is, where tests go in a Swift
module, the anti-patterns, and the rules of the loop. Every section applies on
every cycle — consult them during the loop, not after.

Default to **Swift Testing** (`@Test`, `#expect`, `#require`). Fall back to XCTest
only when the project's deployment target or toolchain rules it out, or when the
surrounding suite is XCTest and consistency matters more.

## What a good test is

Tests verify behavior through public interfaces, not implementation details. Code
can change entirely; tests shouldn't. A good test reads like a specification —
`"user can check out with a valid cart"` tells you exactly what capability exists,
and it survives refactors because it doesn't care about internal structure.

See [tests.md](references/tests.md) for examples and
[test-doubles.md](references/test-doubles.md) for when to fake a dependency.

## Seams: where tests go

A **seam** is the public boundary you test at: the interface where you observe
behavior without reaching inside. Tests live at seams, never against internals.

**Test only at pre-agreed seams.** Before writing any test, write down the seams
under test and confirm them with the user. You can't test everything, so agreeing
the seams up front is how effort lands on critical paths and complex logic instead
of every edge case.

Ask: "What's the public interface, and which seams should we test?"

### Swift's seams, specifically

| Seam | Test it | Notes |
|---|---|---|
| A module's `public` API | ✅ yes | The strongest seam. Use a plain `import`, not `@testable`. |
| A `protocol` boundary | ✅ yes | Where injection happens; the natural place for fakes. |
| A `@MainActor` type's methods | ✅ yes | Mark the test `@MainActor` rather than hopping actors inside it. |
| An `actor`'s public methods | ✅ yes | `await` normally; don't reach for internal state. |
| `internal` symbols via `@testable` | ⚠️ sparingly | See below. |
| `private` / `fileprivate` | ❌ never | If you need to, the seam is wrong. |
| SwiftUI `View.body` | ❌ never | Test the model driving it. |

### `@testable import` is a smell, not a tool

`@testable import` raises `internal` symbols to test visibility. That is precisely
the "reach inside and test the implementation" anti-pattern this skill warns
about — Swift just makes it a one-word opt-in.

Use it only when the type genuinely should stay `internal` to the module *and*
its behavior isn't observable through any public seam. When you find yourself
using it constantly, the module's public interface is too thin: promote the seam
rather than widening test visibility.

## Anti-patterns

- **Implementation-coupled**: fakes internal collaborators, tests `private`
  methods, or verifies through a side channel — querying the store directly
  instead of reading back through the interface. The tell: the test breaks when
  you refactor but behavior hasn't changed.
- **Tautological**: the assertion recomputes the expected value the way the code
  does (`#expect(add(a, b) == a + b)`, a snapshot derived by hand the same way),
  so it passes by construction and can never disagree with the code. Expected
  values must come from an independent source: a known-good literal, a worked
  example, the spec.
- **Horizontal slicing**: writing all tests first, then all implementation. Bulk
  tests verify *imagined* behavior — you test the shape of things rather than
  real behavior, and you commit to test structure before understanding the
  implementation. Work in **vertical slices**: one test → one implementation →
  repeat, each test a tracer bullet that responds to what the last cycle taught.
- **Async sleeping**: `Task.sleep` to "let things settle" trades a fast test for a
  slow flaky one. Await the actual work, use a confirmation, or inject a clock.

## Rules of the loop

- **Red before green.** Write the failing test first, then only enough code to
  pass it. Don't anticipate future tests or add speculative features.
- **One slice at a time.** One seam, one test, one minimal implementation.
- **Refactoring is not part of the loop.** It belongs to review, not the
  red → green cycle.
- **A test that has never failed is not yet a test.** If it passed the first time
  you ran it, break the implementation deliberately and confirm it goes red.

## Running the loop

```bash
swift test
```

```bash
xcodebuild test -scheme YourScheme -destination 'platform=iOS Simulator,name=iPhone 17'
```

Prefer filtering to the slice you're on — a full suite run per cycle kills the
rhythm that makes TDD worth doing.

---

*Adapted for Swift from [`mattpocock/skills`](https://github.com/mattpocock/skills)
(`engineering/tdd`), MIT © Matt Pocock. The seam/anti-pattern/loop framing is his;
the Swift Testing idioms, the seam table, `@testable` guidance, and the async
material are additions. Full license in [NOTICE.md](NOTICE.md).*
