<div align="center">

# iOSskillsCollection

**A lean, curated collection of iOS & Swift Agent Skills.**

Sixteen skills you can install in one command — plus a vetted registry
pointing at the best iOS skills the community has already built.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Agent Skills](https://img.shields.io/badge/format-Agent%20Skills-000)](https://code.claude.com/docs/en/skills)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-ready-D97757)](#claude-code)
[![Codex](https://img.shields.io/badge/Codex-ready-10A37F)](#codex)
[![Cursor](https://img.shields.io/badge/Cursor-ready-000)](#cursor)

</div>

---

## Why this exists

Most iOS skill repos take one of two shapes: a handful of skills from one author,
or a mega-dump of 200+ vendored copies that go stale the day they're committed.

This one is deliberately different:

- **Every skill says where it came from.** Three are original. Seven are Swift
  rewrites of [`mattpocock/skills`](https://github.com/mattpocock/skills). Six came
  from [`Dimillian/Skills`](https://github.com/Dimillian/Skills) via local project
  copies and are locally modified. All thirteen derivatives carry a `NOTICE.md`
  with the upstream copyright, and it installs alongside the skill.
- **Everything else is linked, not vendored.** The [registry](registry/skills.json)
  indexes 25 external sources. `--add` clones from the *author's* repo at install
  time, so you always get their current version and they keep the credit.
- **One installer, four tools.** Claude Code, Codex, Cursor, and OpenCode.

---

## The skills

### Original

| Skill | What it does |
|---|---|
| [`apple-foundation-models`](skills/apple-foundation-models) | On-device AI with Apple's Foundation Models: `SystemLanguageModel`, guided generation, tool calling, safety, localization. **10 reference docs, ~130 KB.** |
| [`instruments-profile-session`](skills/instruments-profile-session) | Instruments' record button as a workflow: play → interact → stop → one report fusing trace analysis with console logs. Bridges XcodeBuildMCP and XcodeInstrumentsMCP. |
| [`gh-issue-fix-flow`](skills/gh-issue-fix-flow) | Issue number → `gh` intake → fix → build/test → closing commit → push. |

### From `Dimillian/Skills` (MIT)

Six skills that reached this repo through local project copies. Thomas Ricouard
published them on 2025-12-30; the copies here date from 2026-01-11 and have
drifted since. **They are not a mirror** — for the maintained versions go to
[`Dimillian/Skills`](https://github.com/Dimillian/Skills), or `./install.sh --add dimillian-skills`.

| Skill | What it does |
|---|---|
| [`swiftui-liquid-glass`](skills/swiftui-liquid-glass) | Build and review iOS 26+ Liquid Glass UI — `glassEffect`, `GlassEffectContainer`, glass button styles, with availability fallbacks. |
| [`swiftui-performance-audit`](skills/swiftui-performance-audit) | Diagnose janky scrolling, excessive view updates, and layout thrash from code review, escalating to Instruments when review isn't enough. |
| [`swiftui-view-refactor`](skills/swiftui-view-refactor) | Consistent view ordering, dependency injection, and correct `@Observable` usage. Includes an MV pattern reference drawn from Ricouard's "SwiftUI in 2025: Forget MVVM". |
| [`swift-concurrency-expert`](skills/swift-concurrency-expert) | Swift 6.2 Approachable Concurrency: smallest-safe-fix triage for isolation and `Sendable` errors. |
| [`ios-debugger-agent`](skills/ios-debugger-agent) | Drive a booted simulator via XcodeBuildMCP — build, launch, tap through the UI, capture logs, diagnose runtime behavior. |
| [`app-store-changelog`](skills/app-store-changelog) | Turn git history since the last tag into user-facing App Store "What's New" copy. |

### Adapted from `mattpocock/skills` (MIT)

Seven skills rewritten for Swift and Xcode. His framing, our idioms — each carries
a `NOTICE.md` recording exactly what was kept and what is new.

| Skill | What changed for iOS |
|---|---|
| [`swift-tdd`](skills/swift-tdd) | Swift Testing idioms, a table of Swift's real seams, why `@testable import` is the reach-inside anti-pattern with a one-word opt-in, and test doubles via protocols/closures/`URLProtocol` — Swift has no runtime mocking, so the `jest.mock` material was replaced outright. |
| [`swift-diagnosing-bugs`](skills/swift-diagnosing-bugs) | Ten iOS ways to build a feedback loop (XCTest, previews, `simctl`, LLDB breakpoint actions, `os_log`, Instruments, sanitizers, `git bisect run`), Apple determinism traps, and a crash-log termination-reason table. |
| [`swift-code-review`](skills/swift-code-review) | A Swift review baseline — retain cycles, main-thread violations, unsafe concurrency escapes, SwiftUI property-wrapper and `ForEach` identity criteria — on top of his two-axis structure. No dependency on his setup skill. |
| [`swift-domain-modeling`](skills/swift-domain-modeling) | Making illegal states unrepresentable with enums, domain types over primitive obsession, and the Apple decisions that actually earn an ADR (SwiftData vs Core Data, migration strategy, deployment target). |
| [`xcode-merge-conflicts`](skills/xcode-merge-conflicts) | `project.pbxproj` conflicts done right — multi-section membership, `plutil -lint` verification, the Tuist/XcodeGen regeneration rule — plus `Package.resolved`, `.xcstrings`, schemes, asset catalogs, and `.xcdatamodeld`. |
| [`swift-pre-commit`](skills/swift-pre-commit) | Full reimplementation: a plain git hook driving SwiftFormat and SwiftLint on staged files, with `core.hooksPath` so the team actually gets the hooks. No Node toolchain in an Xcode repo. |
| [`apple-docs-research`](skills/apple-docs-research) | An eight-tier Apple source hierarchy (headers → docs → Swift Evolution → WWDC), availability matrices, deprecation states, and version-stamping every finding so notes don't rot. |

Plus the [`ios-swift-engineer`](agents/ios-swift-engineer.md) subagent for Claude Code.

> **On Swift Concurrency and SwiftUI:** this repo deliberately ships neither.
> [Antoine van der Lee](https://github.com/AvdLee) already maintains the definitive
> skills for both, and they're better than anything worth duplicating here.
> Pull them straight from him:
>
> ```bash
> ./install.sh --add avdlee-swift-concurrency --add avdlee-swiftui
> ```

---

## Install

### skills.sh (one command, any agent)

```bash
npx skills add https://github.com/Vvlladd/iOSskillsCollection
```

Installs into `.agents/skills/` — the universal location read by Codex, Cursor,
Gemini CLI, Copilot, Warp and a dozen others — and symlinks `.claude/skills/` for
Claude Code. Files are yours to edit. Add `--skill <name>` for just one:

```bash
npx skills add https://github.com/Vvlladd/iOSskillsCollection --skill apple-foundation-models
```

### Claude Code

```bash
/plugin marketplace add Vvlladd/iOSskillsCollection
```

```bash
/plugin install ios-skills-collection@ios-skills-collection
```

### Codex

```bash
git clone https://github.com/Vvlladd/iOSskillsCollection.git && cd iOSskillsCollection && ./install.sh --target codex
```

Codex discovers skills in `~/.codex/skills/`. See [where to save skills](https://developers.openai.com/codex/skills/#where-to-save-skills).

### Cursor

```bash
git clone https://github.com/Vvlladd/iOSskillsCollection.git && cd iOSskillsCollection && ./install.sh --target cursor
```

### Any / all of the above

```bash
./install.sh --target all
```

```bash
./install.sh --project
```

`--project` installs into the current repo (`./.claude/skills`, `./.codex/skills`, …)
so the skills version-control with your app and reach the whole team.

Run `./install.sh --dry-run` first if you want to see exactly what lands where.

---

## Apple's own skills (don't install them from here)

Xcode 27 ships seven agent skills, and one command exports them from **your**
install:

```bash
xcrun mcpbridge run-agent skills export --output-dir ~/.claude/skills
```

Xcode must be running — the tool connects to it. Verified on Xcode 27.0 Beta 5;
it exports `swiftui-specialist`, `swiftui-whats-new-27`, `uikit-app-modernization`,
`test-modernizer`, `device-interaction`, `c-bounds-safety`, and
`audit-xcode-security-settings`.

**These are deliberately not vendored here, and you should be wary of any repo
that does vendor them.** They are Apple's content, shipped under the Xcode
license, with no grant permitting redistribution — which is why the mirrors of
them on GitHub carry no license at all. Everyone with Xcode already has them one
command away, they change with every Xcode build, and a vendored copy silently
misrepresents which build it came from.

They overlap this collection in places — Apple's `swiftui-specialist` against the
SwiftUI skills here, `test-modernizer` against [`swift-tdd`](skills/swift-tdd),
`device-interaction` against [`ios-debugger-agent`](skills/ios-debugger-agent).
Apple's are authoritative on new API and deprecations; these go deeper on
workflow and review. Install both and prefer Apple's on questions of fact.

## The registry

25 external iOS/Swift skill sources, each hand-checked for quality and license.

```bash
./install.sh --list
```

```bash
./install.sh --add avdlee-swiftui
```

`--add` is repeatable, and also takes any GitHub repo directly:

```bash
./install.sh --add avdlee-swift-concurrency --add avdlee-swiftui --add AvdLee/Core-Data-Agent-Skill
```

### Refreshing an app that already vendored skills

If a project has skills copied into its `.claude/skills/` (or `.agents/skills/`),
those copies are frozen at whatever the author had shipped that day. Point the
installer at the project with `--project` to replace them with current upstream:

```bash
cd ~/path/to/YourApp
```

```bash
~/path/to/iOSskillsCollection/install.sh --add avdlee-swift-concurrency --add avdlee-swiftui --project
```

`--add` overwrites a skill directory of the same name, so re-running it *is* the
update mechanism. Add `--dry-run` first to see exactly what gets replaced.

This is the whole reason the registry links instead of vendors: run that command
again in six months and you get Antoine's six-months-newer skill, not a copy of
today's frozen in your repo.

A sample of what's indexed:

| Source | Author | License | Covers |
|---|---|---|---|
| [SwiftUI-Agent-Skill](https://github.com/AvdLee/SwiftUI-Agent-Skill) ★3.5k | Antoine van der Lee | MIT | 26 reference files: state, animation, charts, macOS, `.trace` analysis |
| [Swift-Concurrency-Agent-Skill](https://github.com/AvdLee/Swift-Concurrency-Agent-Skill) ★1.6k | Antoine van der Lee | MIT | actors, `Sendable`, Swift 6 migration, linting |
| [Xcode-Build-Optimization](https://github.com/AvdLee/Xcode-Build-Optimization-Agent-Skill) ★1.2k | Antoine van der Lee | MIT | 6 skills: benchmark, analyze, fix build times |
| [agent-scripts](https://github.com/steipete/agent-scripts) ★6.6k | Peter Steinberger | MIT | 54 skills: Instruments, Hopper, Xcode sync, Mac release |
| [Skills](https://github.com/Dimillian/Skills) ★3.9k | Thomas Ricouard | MIT | the origin of the widely-copied SwiftUI skills, plus swarm patterns |
| [agent-rules](https://github.com/steipete/agent-rules) ★5.7k | Peter Steinberger | MIT | `modern-swift`, compact Swift 6 migration, Cursor `.mdc` rules |
| [swift-ios-skills](https://github.com/dpearson2699/swift-ios-skills) ★1k | dpearson2699 | ⚠️ custom | 84 framework skills, AlarmKit → TabletopKit |
| [claude-code-apple-skills](https://github.com/rshankras/claude-code-apple-skills) ★684 | Ravi Shankar | MIT | code plus ASO, monetization, legal, release review |
| [apple-skills](https://github.com/Prisma-Labs-Dev/apple-skills) ★323 | Prisma Labs | MIT | 32 framework-scoped skills + Apple docs index |
| [xcode27-skills](https://github.com/superagents-lab/xcode27-skills) ★299 | superagents-lab | ⚠️ none | Apple's own Xcode 27 skills |

⚠️ marks sources with a non-standard or missing license — fine to install and use,
but check before redistributing. `--list` shows the full set with these flags inline.

---

## Repo layout

```
skills/                  16 skills (9 original, 7 adapted)
agents/                  ios-swift-engineer subagent
registry/skills.json     curated index of external sources
install.sh               installer for Claude Code / Codex / Cursor / OpenCode
.claude-plugin/          Claude Code marketplace + plugin manifest
.codex-plugin/           Codex plugin manifest
```

Every skill is a plain directory with a `SKILL.md` and optional `references/`, which
is the [Agent Skills open format](https://code.claude.com/docs/en/skills) — so these
also work in Gemini CLI, pi, Autohand, and anything else that reads it.

---

## Pairing with engineering-process skills

These skills cover *how iOS works*. They pair with skills covering *how to work* —
[`mattpocock/skills`](https://github.com/mattpocock/skills) (MIT) being the best of
those. **The seven worth adapting are already adapted above**; don't install his
versions on top of them. For the rest, install selectively.

**Drop in unchanged** — these reason about git diffs, architecture and discipline,
with nothing language-specific in them:

```bash
npx skills add https://github.com/mattpocock/skills --skill handoff --skill implement --skill improve-codebase-architecture --skill resolving-merge-conflicts
```

Also clean: `teach`, `grilling`, `grill-with-docs`, `wizard`, `wait-what`,
`to-questionnaire`, `git-guardrails-claude-code`.

**Deliberately not adapted** — `grilling`, `teach`, `wait-what`, `wizard`,
`writing-for-agents` and friends are pure process. An "iOS version" of them would
be his text with a different name on it, which is exactly the laundering this repo
exists to avoid. Install his originals; he wrote them, he maintains them.

**Expect a prerequisite** — `triage`, `to-spec`, `to-tickets`, `wayfinder` and
`ask-matt` read `docs/agents/issue-tracker.md`, which only exists after running his
`setup-matt-pocock-skills`. They aren't broken without it, they just stop and ask.
Note that setup writes *his* conventions into your repo.

**Skip on iOS** — `migrate-to-shoehorn` is a TypeScript-only library. His
`setup-pre-commit` is superseded by [`swift-pre-commit`](skills/swift-pre-commit)
here. His `in-progress/` directory is flagged unstable by him; treat it that way.

---

## Credits

This collection stands on other people's work, and the registry exists so that
credit stays with them rather than being laundered through a copy:

- **[Antoine van der Lee](https://www.avanderlee.com)** ([@AvdLee](https://github.com/AvdLee)) — the
  Swift Concurrency, SwiftUI, Core Data, Swift Testing, and Xcode Build Optimization
  skills, and the repo conventions this one follows.
- **[Pol Piella](https://polpiella.dev)** ([@polpielladev](https://github.com/polpielladev)) — iOS
  tooling and Xcode Cloud work; his SwiftUI skill is a fork of Antoine's.
- **[Thomas Ricouard](https://dimillian.app)** ([@Dimillian](https://github.com/Dimillian)) —
  author of [Ice Cubes](https://github.com/Dimillian/IceCubesApp) and of
  [`Dimillian/Skills`](https://github.com/Dimillian/Skills), the origin of the SwiftUI
  agent skills now circulating widely in the iOS community. Six of the skills bundled
  here are his work, modified.
- **[Peter Steinberger](https://steipete.me)** ([@steipete](https://github.com/steipete)) —
  [`agent-scripts`](https://github.com/steipete/agent-scripts) and
  [`agent-rules`](https://github.com/steipete/agent-rules): the deepest macOS and
  release-engineering coverage anywhere, and the attribution practice this repo
  follows for shared skills.
- **[Matt Pocock](https://www.aihero.dev)** ([@mattpocock](https://github.com/mattpocock)) — not iOS,
  but [`mattpocock/skills`](https://github.com/mattpocock/skills) is the model for how a
  skills repo should be built. Install it *selectively* alongside this one — see
  [the pairing note](#pairing-with-engineering-process-skills).
- Every author listed in [`registry/skills.json`](registry/skills.json).

## Contributing

New skill or a source worth indexing? See [CONTRIBUTING.md](CONTRIBUTING.md).
Registry additions need a working repo link, an accurate license, and a one-line
reason it earns a slot.

## License

[MIT](LICENSE) © Vlad Toma.

Covers the skills in `skills/`, the agent, and the tooling. External skills reached
through the registry stay under **their own authors' licenses** — nothing from them
is redistributed here.
