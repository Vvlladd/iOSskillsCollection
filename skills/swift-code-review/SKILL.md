---
name: swift-code-review
description: Review a Swift diff against a fixed point on two axes - does it follow the repo's standards and Swift idiom, and does it do what the originating issue asked. Use when reviewing a branch, a PR, or work in progress in an iOS/macOS codebase.
---

# Swift Code Review

Two-axis review of the diff between `HEAD` and a fixed point:

- **Standards** — does it conform to the repo's conventions and Swift idiom?
- **Spec** — does it faithfully implement what was asked?

Run the axes independently so findings from one don't contaminate the other, then
report them side by side.

## 1. Pin the fixed point

Whatever the user names — a SHA, a branch, a tag, `main`, `HEAD~5`. If they
didn't say, ask.

```bash
git rev-parse <fixed-point> && git diff --stat <fixed-point>...HEAD
```

Three-dot, so the comparison is against the merge-base. Confirm the ref resolves
and the diff is non-empty **before** going further — a bad ref should fail here,
not halfway through a review.

```bash
git log <fixed-point>..HEAD --oneline
```

## 2. Find the spec

In order: issue references in the commit messages (`#123`, `Closes #45`), then a
path the user passed, then a spec under `docs/` or `specs/` matching the branch
name. If there's none, say so and review the Standards axis only — don't invent
acceptance criteria.

## 3. Find the standards

Read whatever the repo documents — `CONTRIBUTING.md`, `CODING_STANDARDS.md`,
`CLAUDE.md`, `.swiftlint.yml`, `.swiftformat`. **The repo always overrides this
skill.** Where a documented convention contradicts anything below, the repo wins.

**Skip anything tooling already enforces.** If SwiftFormat governs line width and
SwiftLint governs force-unwrapping, do not spend review attention there — the
pipeline is more reliable at it than you are.

## 4. The Swift baseline

On top of the repo's own standards, these apply even when a repo documents
nothing. Each is a labelled heuristic — "possible retain cycle" — never an
automatic violation.

### Correctness and safety

- **Force unwrap / force try / force cast** on anything not a compile-time
  invariant. `!` on an `@IBOutlet` is fine; `!` on a decoded payload is a crash
  report waiting to be filed.
- **Retain cycles** — an escaping closure capturing `self` strongly, a delegate
  that isn't `weak`, a `Task` holding a view model past its lifetime. Ask of each
  new closure: what owns this, and when does it die?
- **Unhandled errors** — `try?` that silently discards a failure the user should
  see. Swallowing an error is a product decision, not a syntax choice; it needs
  to be deliberate.
- **Main-thread violations** — UI mutation from a non-isolated context, or
  `@MainActor` sprinkled to silence a warning rather than to express where the
  code truly runs.
- **Unsafe concurrency escapes** — `@unchecked Sendable`, `nonisolated(unsafe)`,
  or `@preconcurrency` without a documented invariant justifying it.
- **Blocking the main actor** — synchronous file, keychain, or database work
  inside a `@MainActor` method.

### API design

- **Primitive obsession** — a `String` standing in for an identifier, or a
  `Double` for money. Give the concept a type.
- **Illegal states representable** — parallel `isLoading` / `value` / `error`
  fields where an enum belongs.
- **Naming against the guidelines** — `getFoo()` instead of `foo`, argument
  labels that don't read at the call site, a method whose name says HOW.
- **Access control drift** — new `public` API on a module's surface that the
  change didn't need to expose. Public is a promise; it's the hardest thing here
  to walk back.
- **Speculative generality** — a protocol with one conformer, a generic parameter
  with one instantiation, a hook for a requirement the spec doesn't have.

### SwiftUI

- **Wrong property wrapper** — `@State` for injected data, `@StateObject` vs
  `@ObservedObject` confusion, `@Observable` mixed with `@Published`.
- **Work in `body`** — sorting, filtering, formatting, or date math re-executed
  on every invalidation.
- **Unstable `ForEach` identity** — `id: \.self` on a mutable collection, or an
  index as identity. This shows up later as animation glitches and lost state,
  never as a build failure.
- **Over-broad invalidation** — a single observable object driving a whole screen
  so unrelated edits redraw everything.

### Tests

- Does the change carry tests at a seam that would actually have caught the bug?
- Are they behavioral, or coupled to implementation? (See `swift-tdd`.)
- Are new async paths tested without `Task.sleep`?

### General smells

Match these against the diff, from Fowler's *Refactoring* ch. 3:

- **Mysterious name** → rename; if no honest name comes, the design is murky
- **Duplicated code** → extract the shared shape
- **Feature envy** — a method reaching into another type's data more than its own
  → move it onto the data
- **Data clumps** — the same parameters travelling together → they want to be a type
- **Repeated switches** on the same enum across the diff → polymorphism, or one
  shared mapping
- **Shotgun surgery** — one logical change forcing scattered edits → gather what
  changes together
- **Divergent change** — one file edited for several unrelated reasons → split it
- **Message chains** — `a.b().c().d()` the caller shouldn't depend on
- **Middle man** — a type that mostly just forwards

## 5. Report

Give the two axes separately — a spec gap and a style nit are different kinds of
problem and shouldn't be interleaved.

For each finding: **file and line**, what's wrong, why it matters, and the
concrete fix. Rank by severity, not by file order.

Separate **must-fix** (crashes, data loss, spec violations, concurrency unsafety)
from **should-fix** (design, naming) from **optional** (taste). Say plainly when
an axis found nothing — a clean report is a result, and padding it with nits
trains people to ignore reviews.

---

*Adapted for Swift from [`mattpocock/skills`](https://github.com/mattpocock/skills)
(`engineering/code-review`), MIT © Matt Pocock. The two-axis structure and the Fowler
smell baseline are his; the Swift/SwiftUI/concurrency criteria are new. His version
depends on a `docs/agents/issue-tracker.md` produced by his setup skill; that
dependency is removed here. Full license in [NOTICE.md](NOTICE.md).*
