<div align="center">

# iOSskillsCollection

**A lean, curated collection of iOS & Swift Agent Skills.**

Nine original skills you can install in one command — plus a vetted registry
pointing at the best iOS skills the community has already built.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Agent Skills](https://img.shields.io/badge/format-Agent%20Skills-000)](https://code.claude.com/docs/en/skills)
[![skills.sh](https://skills.sh/b/Vvlladd/iOSskillsCollection)](https://skills.sh/Vvlladd/iOSskillsCollection)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-ready-D97757)](#claude-code)
[![Codex](https://img.shields.io/badge/Codex-ready-10A37F)](#codex)
[![Cursor](https://img.shields.io/badge/Cursor-ready-000)](#cursor)

</div>

---

## Why this exists

Most iOS skill repos take one of two shapes: a handful of skills from one author,
or a mega-dump of 200+ vendored copies that go stale the day they're committed.

This one is deliberately different:

- **Bundled = original only.** The nine skills in `skills/` are written here. Nothing
  is a re-upload of somebody else's work.
- **Everything else is linked, not vendored.** The [registry](registry/skills.json)
  indexes 21 external sources. `--add` clones from the *author's* repo at install
  time, so you always get their current version and they keep the credit.
- **One installer, four tools.** Claude Code, Codex, Cursor, and OpenCode.

---

## The skills

| Skill | What it does |
|---|---|
| [`apple-foundation-models`](skills/apple-foundation-models) | On-device AI with Apple's Foundation Models: `SystemLanguageModel`, guided generation, tool calling, safety, localization. **10 reference docs, ~130 KB.** |
| [`instruments-profile-session`](skills/instruments-profile-session) | Instruments' record button as a workflow: play → interact → stop → one report fusing trace analysis with console logs. Bridges XcodeBuildMCP and XcodeInstrumentsMCP. |
| [`swiftui-liquid-glass`](skills/swiftui-liquid-glass) | Build and review iOS 26+ Liquid Glass UI — `glassEffect`, `GlassEffectContainer`, glass button styles, with availability fallbacks. |
| [`swiftui-performance-audit`](skills/swiftui-performance-audit) | Diagnose janky scrolling, excessive view updates, and layout thrash from code review, escalating to Instruments when review isn't enough. |
| [`swiftui-view-refactor`](skills/swiftui-view-refactor) | Consistent view ordering, dependency injection, and correct `@Observable` usage. Includes MV pattern reference. |
| [`swift-concurrency-expert`](skills/swift-concurrency-expert) | Swift 6.2 Approachable Concurrency: smallest-safe-fix triage for isolation and `Sendable` errors. |
| [`ios-debugger-agent`](skills/ios-debugger-agent) | Drive a booted simulator via XcodeBuildMCP — build, launch, tap through the UI, capture logs, diagnose runtime behavior. |
| [`app-store-changelog`](skills/app-store-changelog) | Turn git history since the last tag into user-facing App Store "What's New" copy. |
| [`gh-issue-fix-flow`](skills/gh-issue-fix-flow) | Issue number → `gh` intake → fix → build/test → closing commit → push. |

Plus the [`ios-swift-engineer`](agents/ios-swift-engineer.md) subagent for Claude Code.

> **On Swift Concurrency and SwiftUI:** this repo deliberately ships neither.
> [Antoine van der Lee](https://github.com/AvdLee) already maintains the definitive
> skills for both, and they're better than anything worth duplicating here.
> Get them with `./install.sh --add avdlee-swift-concurrency avdlee-swiftui`.

---

## Install

### skills.sh (one command, any agent)

```bash
npx skills add https://github.com/Vvlladd/iOSskillsCollection
```

Copies editable skill files into your project — hack on them freely. Add
`--skill <name>` for just one:

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

## The registry

21 external iOS/Swift skill sources, each hand-checked for quality and license.

```bash
./install.sh --list
```

```bash
./install.sh --add avdlee-swiftui
```

`--add` also takes any GitHub repo directly:

```bash
./install.sh --add AvdLee/Core-Data-Agent-Skill
```

A sample of what's indexed:

| Source | Author | License | Covers |
|---|---|---|---|
| [SwiftUI-Agent-Skill](https://github.com/AvdLee/SwiftUI-Agent-Skill) ★3.5k | Antoine van der Lee | MIT | 26 reference files: state, animation, charts, macOS, `.trace` analysis |
| [Swift-Concurrency-Agent-Skill](https://github.com/AvdLee/Swift-Concurrency-Agent-Skill) ★1.6k | Antoine van der Lee | MIT | actors, `Sendable`, Swift 6 migration, linting |
| [Xcode-Build-Optimization](https://github.com/AvdLee/Xcode-Build-Optimization-Agent-Skill) ★1.2k | Antoine van der Lee | MIT | 6 skills: benchmark, analyze, fix build times |
| [swift-ios-skills](https://github.com/dpearson2699/swift-ios-skills) ★1k | dpearson2699 | ⚠️ custom | 84 framework skills, AlarmKit → TabletopKit |
| [claude-code-apple-skills](https://github.com/rshankras/claude-code-apple-skills) ★684 | Ravi Shankar | MIT | code plus ASO, monetization, legal, release review |
| [apple-skills](https://github.com/Prisma-Labs-Dev/apple-skills) ★323 | Prisma Labs | MIT | 32 framework-scoped skills + Apple docs index |
| [xcode27-skills](https://github.com/superagents-lab/xcode27-skills) ★299 | superagents-lab | ⚠️ none | Apple's own Xcode 27 skills |

⚠️ marks sources with a non-standard or missing license — fine to install and use,
but check before redistributing. `--list` shows the full set with these flags inline.

---

## Repo layout

```
skills/                  9 original skills (Agent Skills open format)
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

## Credits

This collection stands on other people's work, and the registry exists so that
credit stays with them rather than being laundered through a copy:

- **[Antoine van der Lee](https://www.avanderlee.com)** ([@AvdLee](https://github.com/AvdLee)) — the
  Swift Concurrency, SwiftUI, Core Data, Swift Testing, and Xcode Build Optimization
  skills, and the repo conventions this one follows.
- **[Pol Piella](https://polpiella.dev)** ([@polpielladev](https://github.com/polpielladev)) — iOS
  tooling and Xcode Cloud work; his SwiftUI skill is a fork of Antoine's.
- **[Matt Pocock](https://www.aihero.dev)** ([@mattpocock](https://github.com/mattpocock)) — not iOS,
  but [`mattpocock/skills`](https://github.com/mattpocock/skills) is the model for how a
  skills repo should be built, and worth installing alongside this one for the
  engineering-process half (`tdd`, `code-review`, `diagnosing-bugs`, `handoff`).
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
