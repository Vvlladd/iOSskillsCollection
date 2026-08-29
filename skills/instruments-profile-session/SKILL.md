---
name: instruments-profile-session
description: Use when the user wants to profile an iOS app the way Instruments feels — hit play, interact with the running app, hit stop, and get one report with the trace analysis plus the console logs. Orchestrates the ios-preview "play button" with the XcodeInstruments MCP profiler. Triggers — "profile this scenario", "record while I tap through X", "play, do Y, stop and show me leaks/CPU", "profile the running app and include the logs".
version: 1.0.0
---

# Profile Session

Mimics the Xcode Instruments record button across two MCPs that already speak the
same language (a simulator **UDID**). Neither side reimplements the other:

- **ios-preview owns the buttons** — building, launching (▶ play), UI automation, and
  os_log capture. It resolves exactly one simulator and caches it in
  `.claude/ios-preview.env` (`IOS_SIM_UDID`, `IOS_BUNDLE_ID`, `IOS_PRODUCT_NAME`).
- **XcodeInstruments owns the profiler** — it *attaches* to the app ios-preview
  launched, records an xctrace template, and fuses trace + snapshots + logs into one
  report at stop.

The contract between them is just three values: **simulator UDID, bundle id, captured
log text.** A handoff, not a coupling.

## When to use

The user wants to profile a *scenario* (not a one-shot snapshot): launch the app,
exercise a flow (manually or via automation), then stop and read leaks / CPU / energy
with the console logs alongside. For a quick non-interactive capture, prefer
`mcp__xcode-instruments__quick_profile` instead.

## The loop

1. **▶ Play — launch via ios-preview.** Prefer the **model-invokable tool**
   `mcp__plugin_ios-preview_xcodebuildmcp__build_run_sim` so you can drive the whole
   loop in one go (the `/ios-preview:start` slash command is `disable-model-invocation`,
   i.e. the *user* must type it — fine if they prefer to, but you can't call it). This
   boots the sim and launches the app (visible in ios-preview's pane). Capture the
   **bundle id** (`get_app_bundle_id` / `IOS_BUNDLE_ID`) and the launched **PID**.

2. **📋 Start log capture.** Begin os_log capture for the app
   (`mcp__plugin_ios-preview_xcodebuildmcp__start_sim_log_cap` with `captureConsole: true`,
   or the ios-preview logs pane). Keep the returned log-session id.

3. **● Start recording — attach immediately, keyed off the PID (no sleep/timer).**
   The moment `build_run_sim` returns the app is running, so call
   `mcp__xcode-instruments__start_recording` with **`bundle_id`** and a `profile`
   (`memory` / `cpu` / `energy`) or `template` right away. It resolves the running
   app's PID + simulator automatically (defaulting the device from
   `.claude/ios-preview.env`) — no PID or device to type. If it reports the app isn't
   running yet, the launch hasn't settled: re-resolve by PID, don't guess with a delay.
   Keep the returned `session_id`. This back-to-back launch→attach is the "safe
   auto-attach" — one request, the recorder rides along with ios-preview's play.

4. **👆 Interact.** Either let the user drive the app by hand, or automate a
   *repeatable* scenario with ios-preview
   (`tap` / `swipe` / `type_text` / `button` / `gesture`). For snapshots at key
   moments: `mcp__xcode-instruments__recording_snapshot(session_id, type: "heap"|"leaks"|"cpu"|"vmmap")`.

5. **⏹ Stop + fuse.** Stop log capture
   (`stop_sim_log_cap` → returns the console text), then call
   `mcp__xcode-instruments__stop_recording(session_id, os_log: <that text>)`. The report
   comes back with the trace analysis, the snapshot timeline, **and** a Console Logs
   section (line counts, errors/faults, notable lines) — one artifact. Optionally stop
   the ios-preview pane (`/ios-preview:stop`).

## Guardrails

- **Set the sim once.** If `.claude/ios-preview.env` already has `IOS_SIM_UDID`,
  reuse it — don't re-pick a simulator. That keeps video + logs + trace on the same sim.
- **Memory instruments need a real device.** `detect_leaks` / `heap_summary` /
  `vmmap_summary` cannot attach to a *simulator* process. For leak/heap profiling either
  run on a physical device (ios-preview can launch there too) or fall back to an
  xctrace-only template on the sim — and tell the user which, don't fail silently.
- **Don't type PIDs/UDIDs.** Prefer `bundle_id`; the profiler does the resolution. Only
  fall back to explicit `device` / `pid` if the bundle-id lookup can't find the running
  app (then it isn't actually running — launch it first).
- **React to failures step by step.** If play/build fails, surface ios-preview's stderr
  verbatim and stop; don't start a recording against an app that isn't running.
