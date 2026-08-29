# Contributing

Two ways to contribute, with different bars.

## Adding to the registry (easy)

The registry indexes skills that live in *someone else's* repo. Open a PR
editing `registry/skills.json` with:

```json
{
  "id": "author-short-name",
  "name": "Human Readable Name",
  "repo": "owner/repo",
  "author": "Author Name",
  "license": "MIT",
  "stars": 123,
  "skills": ["skill-one", "skill-two"],
  "topics": ["swiftui", "testing"],
  "why": "One sentence on what this does that nothing else in the registry does."
}
```

Requirements:

- The repo must contain at least one valid `SKILL.md` and be publicly cloneable.
- `license` must be the SPDX id GitHub reports. If there is no license file, use
  `"NONE"` and add a `license_note` — we still list it, we just flag it.
- `why` earns the slot. "It's about SwiftUI" doesn't; "the only one that covers
  Instruments `.trace` parsing" does.
- Verify it installs: `./install.sh --add <your-id> --project --dry-run`

## Adding a bundled skill (higher bar)

`skills/` holds original work only. A new skill needs to be written for this
repo, not copied in from elsewhere. If it exists in another public repo, it
belongs in the registry instead — that keeps the author's name on it and stops
it going stale here.

Structure:

```
skills/<slug>/
├── SKILL.md              # required
└── references/           # optional, for anything long
```

`SKILL.md` frontmatter:

```yaml
---
name: <slug>              # must exactly match the directory name
description: <when an agent should reach for this, and what it covers>
---
```

The `description` is what an agent matches against, so write it as trigger
conditions, not marketing. Say when to use it and on what.

Keep `SKILL.md` to the decision-making layer and push detail into
`references/` — the agent reads the former every time and the latter on demand.

Before opening a PR:

```bash
./scripts/validate.sh
```

## Removing something

If a registry entry breaks, gets archived, or changes license, open an issue or
a PR that removes it. Stale links are worse than a shorter list.
