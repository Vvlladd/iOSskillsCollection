---
name: swift-diagnosing-bugs
description: Diagnosis loop for hard iOS/macOS bugs, crashes, and performance regressions. Use when the user says "diagnose" or "debug this", reports something crashing, hanging, leaking, or dropping frames, or hands over a crash log, a spindump, or an Instruments trace.
---

# Diagnosing Bugs in Swift

> **Driving a device or simulator?** Apple's `device-interaction` skill (via
> `xcrun mcpbridge run-agent skills export`) covers the mechanics — screenshots,
> UI hierarchy, taps. This skill is the diagnostic method that consumes them.

A discipline for hard bugs. Skip phases only when explicitly justified.

## Redact first

This skill has you show commands, output, and captured artifacts. **Redact every
secret before showing it**: write `<REDACTED>` in its place. Device UDIDs, push
tokens, provisioning profiles, API keys in `Info.plist` dumps, and bundle IDs of
unreleased apps all count. If the redacted output is not enough to diagnose the
bug, say so and ask.

## Phase 1: Build a feedback loop

**This is the skill.** Everything else is mechanical. With a tight pass/fail
signal that goes red on *this* bug, you will find the cause. Without one, no
amount of staring at Swift will save you.

Spend disproportionate effort here. Be aggressive. Refuse to give up.

### Ways to construct one, roughly in order

1. **A failing test** at whatever seam reaches the bug — `swift test`, or
   `xcodebuild test -only-testing:Target/Suite/testName`.
2. **A SwiftUI preview** that renders the broken state directly. Fastest loop on
   Apple platforms when the bug is visual or state-driven.
3. **A Swift script or `swift run` entry point** driving the type in isolation,
   diffing output against a known-good literal.
4. **`simctl` automation** — boot a fixed simulator, `simctl launch` with launch
   arguments that jump straight to the broken screen, `simctl io screenshot`.
   Pair with `XCUITest` when a real tap sequence is needed.
5. **Replay a captured payload.** Save the real JSON / push payload / deep link
   to a fixture and feed it through the decode path with no network at all. Most
   "backend bug" reports die here.
6. **An LLDB breakpoint with an action.** `breakpoint set ... --command "po self"
   --auto-continue true` turns a debugger into a logging loop with no rebuild.
7. **`os_log` + `log stream --predicate`.** Signposts (`OSSignposter`) when you
   need timing rather than values.
8. **An Instruments trace** for anything performance-shaped: Time Profiler for
   CPU, Allocations/Leaks for memory, Animation Hitches for scrolling, and
   `xctrace record` to script it.
9. **A stress loop** for concurrency bugs: run the suite with
   `-parallel-testing-enabled YES`, ThreadSanitizer on
   (`-enableThreadSanitizer YES`), Main Thread Checker, and repeat counts.
10. **`git bisect run`** with a scripted `xcodebuild test` when the bug appeared
    between two known-good states.

### Tighten the loop

Treat the loop as a product:

- **Faster?** Test a single target, not the app. Use a preview or a unit test
  over a UI test. Reuse a booted simulator instead of a cold boot per run.
- **Sharper?** Assert the specific symptom, not "didn't crash".
- **More deterministic?** Inject the clock. Seed the RNG. Fix the simulator
  device and OS version. Stub `URLSession` via `URLProtocol` so the network
  can't vary. Disable animations for UI tests.

A 30-second flaky loop is barely better than no loop. A 2-second deterministic
one is a superpower.

### Apple-specific determinism traps

These make loops flaky and are worth eliminating before you suspect your code:

- **Simulator state carried between runs** — `simctl erase` or use a fresh clone.
- **Time zone and locale** — pin them in the scheme; a date bug that only fires
  in one region is a locale bug, not a date bug.
- **Animation timing** — `UIView.setAnimationsEnabled(false)` in UI tests.
- **`Task` ordering** — unstructured `Task {}` gives no ordering guarantee. If
  the test depends on it, that's the bug.
- **Debug vs Release** — optimisation changes lifetimes. A bug that vanishes in
  Debug is often a retain/lifetime or exclusivity issue; reproduce in Release.

### Non-deterministic bugs

The goal is not a clean repro but a **higher reproduction rate**. Loop the
trigger 100×, run tests in parallel, enable sanitizers, add stress. A 50% flake
is debuggable; 1% is not. Keep raising the rate until it is.

For concurrency specifically, turn on **ThreadSanitizer** and the **Main Thread
Checker** before hypothesising — they frequently name the bug outright.

### When you genuinely cannot build a loop

Stop and say so. List what you tried, then ask for: a device sysdiagnose, the
full `.ips` crash log, an Instruments `.trace`, a screen recording with
timestamps, or the exact device/OS pairing that reproduces it. Do **not**
hypothesise without a loop.

### Completion criterion

Phase 1 is done when you can name **one command** you have **already run**, whose
output you can show (redacted), that is:

- [ ] **Red-capable** — drives the real code path and asserts the user's exact
      symptom, so it can go red now and green after the fix
- [ ] **Deterministic** — same verdict every run
- [ ] **Fast** — seconds, not minutes
- [ ] **Agent-runnable** — you can run it unattended

If you catch yourself reading Swift to build a theory before this command
exists, **stop**. Jumping to a hypothesis is the exact failure this prevents.

## Phase 2: Reproduce and minimise

Run the loop. Watch it go red.

- [ ] It produces the failure the **user** described, not a nearby one
- [ ] It reproduces across runs (or at a high enough rate)
- [ ] You captured the exact symptom for later verification

Then shrink to the smallest scenario that still goes red. Cut one thing at a
time — inputs, view hierarchy, callers, config, injected dependencies — rerunning
after each cut. Done when removing any remaining element makes it go green.

### Reading a crash before you minimise

If you have an `.ips` or `.crash`, extract the facts first — they often collapse
the hypothesis space immediately:

| Termination | Usually means |
|---|---|
| `EXC_BAD_ACCESS` (`SIGSEGV`/`SIGBUS`) | Dangling pointer, over-released object, unsafe buffer |
| `EXC_BREAKPOINT` (`SIGTRAP`) | Swift runtime trap — force unwrap of nil, array OOB, overflow, precondition |
| `EXC_CRASH` (`SIGABRT`) | Uncaught ObjC exception, `fatalError`, assertion |
| `0x8badf00d` | Watchdog — you blocked the main thread too long |
| `0xdead10cc` | Held a file/database lock while suspended |
| `EXC_RESOURCE` | Memory limit; jetsam. Check the footprint, not the logic |

Symbolicate before reasoning about frames. Thread 0 is the main thread; a stack
that bottoms out in your code from a `libdispatch` frame means you got called
off-main.

## Phase 3: Hypothesise

Generate **3–5 ranked, falsifiable hypotheses before testing any of them.**
Single-hypothesis generation anchors on the first plausible idea.

> "If X is the cause, then changing Y makes the bug disappear."

If you cannot state the prediction, it's a vibe — sharpen or discard it.

Show the ranked list to the user before testing. They often re-rank instantly
("we just shipped a change to #3"). Don't block on it if they're away.

## Phase 4: Instrument

Each probe maps to a specific prediction. **Change one variable at a time.**

1. **LLDB first.** One breakpoint beats ten `print`s. `po`, `p`, `bt`, `frame
   variable`, `watchpoint set variable` for "who mutated this", and
   `breakpoint set --one-shot`.
2. **Targeted `os_log`** at the boundaries that distinguish hypotheses — with a
   dedicated subsystem so `log stream` can filter to it.
3. **Never** "log everything and grep".

**Tag every temporary log** with a unique prefix like `[DEBUG-a4f2]` so cleanup
is one grep. Untagged logs survive forever; tagged ones die.

**Memory branch:** for leaks and retain cycles, use the memory graph debugger
and Instruments Leaks rather than logs. A `deinit` that never fires is the
cheapest possible probe — add one before reaching for tooling.

**Performance branch:** logs are usually wrong. Baseline with a signpost or
`XCTMeasure`, then bisect. Measure first, fix second. This repo's
`instruments-profile-session` skill drives that loop end to end.

## Phase 5: Fix and regression test

Write the regression test **before** the fix — but only if a **correct seam**
exists. A correct seam exercises the real bug pattern as it occurs at the call
site. If the only reachable seam is too shallow, a test there gives false
confidence.

**If no correct seam exists, that is itself the finding.** The architecture is
preventing the bug from being locked down. Say so.

Otherwise: turn the minimised repro into a failing test, watch it fail, apply the
fix, watch it pass, then rerun the Phase 1 loop against the original
un-minimised scenario.

See this repo's `swift-tdd` skill for what makes that test worth keeping.

## Phase 6: Cleanup

- [ ] Original repro no longer reproduces
- [ ] Regression test passes, or the absent seam is documented
- [ ] All `[DEBUG-...]` instrumentation removed (grep the prefix)
- [ ] Temporary breakpoints, sanitizer flags, and scheme edits reverted
- [ ] Throwaway fixtures deleted
- [ ] The correct hypothesis stated in the commit message, so the next person
      inherits the reasoning and not just the patch

---

*Adapted for Swift from [`mattpocock/skills`](https://github.com/mattpocock/skills)
(`engineering/diagnosing-bugs`), MIT © Matt Pocock. Full license in [NOTICE.md](NOTICE.md).*
