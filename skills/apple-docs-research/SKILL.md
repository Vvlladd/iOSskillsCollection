---
name: apple-docs-research
description: Investigate an Apple platform question against primary sources - developer documentation, WWDC sessions, Swift Evolution proposals, and framework headers - and capture findings as a cited Markdown note. Use when researching an API's behavior, availability, deprecation, or the rationale behind a Swift language feature.
---

# Researching Apple APIs

Investigate against **primary sources** and write the findings down with
citations. Apple's platforms punish secondary sources unusually hard: blog posts
go stale one OS release later, and Stack Overflow answers routinely describe
behavior that changed three majors ago.

Where a background agent is available, delegate the reading so you keep working.

## The source hierarchy

Work down this list. Stop as soon as a tier answers the question, and never cite
a lower tier when a higher one covers it.

1. **Framework headers and interfaces.** The ground truth. `⌃⌘J` in Xcode, or
   read the `.swiftinterface`. Availability attributes, deprecation messages, and
   the actual generic constraints live here and nowhere else.
2. **developer.apple.com documentation.** Authoritative, though incomplete —
   absence of documentation is not evidence of absent behavior.
3. **Swift Evolution proposals** (`swiftlang/swift-evolution`). The *only* place
   that records **why** a language feature works the way it does, plus the
   alternatives rejected. Essential for concurrency questions.
4. **WWDC session transcripts.** Often the only explanation of intended usage and
   performance characteristics. Always cite the year — guidance genuinely reverses
   between sessions.
5. **Apple's open-source repos** — `swiftlang/swift`, `swift-foundation`,
   `swift-corelibs-*`. When documentation is silent, the implementation isn't.
6. **Sample code projects** from Apple. Real, compiled, and version-stamped.
7. **Human Interface Guidelines** for design and behavioral conventions.
8. **Release notes** for the specific OS version. Where behavior changes are
   actually recorded.

Community sources — Swift Forums threads, respected blogs — are useful for
*finding* the primary source. Follow the claim back and cite the source that owns
it, not the person who repeated it.

## Questions that need extra care

**"Is this API available on X?"** — availability is a matrix, not a number. Check
the `@available` attribute per platform; iOS, macOS, watchOS, tvOS, and visionOS
frequently diverge. Note what your deployment target actually allows, not what
the newest SDK offers.

**"Is this deprecated?"** — deprecated, obsoleted, and soft-deprecated are three
different states. Apple often soft-deprecates in documentation prose long before
the attribute lands, so the header alone can mislead.

**"Why does concurrency do this?"** — go to Swift Evolution. `SE-0302`
(Sendable), `SE-0306` (actors), `SE-0316` (global actors), `SE-0337` (incremental
migration), `SE-0414` (region-based isolation). The proposals explain intent that
no documentation page does.

**"Is this allowed on the App Store?"** — App Review Guidelines only, and quote
the section number. Never infer policy from what another app appears to do.

**"How fast is this?"** — no source is authoritative. Measure it with Instruments
on real hardware. Treat every performance claim without a trace as a hypothesis.

## Write it down

Produce one Markdown file, with every claim carrying its source. Save it where
the repo already keeps notes; match the existing convention, and if there is
none, choose somewhere sensible and say where.

Record for each finding:

- The claim
- The primary source, linked, with **the OS version or WWDC year it applies to**
- Whether it was verified in code, and against which SDK

That last line is what stops the note becoming the next stale blog post. A
finding without a version stamp will be wrong within a year and there'll be no
way to tell when it went wrong.

State explicitly what you could **not** establish. On Apple platforms an
unanswered question is common and worth recording — it stops the next person
repeating the search.

---

*Adapted for Apple platforms from [`mattpocock/skills`](https://github.com/mattpocock/skills)
(`engineering/research`), MIT © Matt Pocock. The primary-source discipline is his; the
Apple source hierarchy is new. Full license in [NOTICE.md](NOTICE.md).*
