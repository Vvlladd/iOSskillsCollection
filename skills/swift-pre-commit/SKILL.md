---
name: swift-pre-commit
description: Set up git pre-commit hooks for a Swift project using SwiftFormat and SwiftLint on staged files, with an optional build or test gate. Use when the user wants pre-commit hooks, commit-time formatting, or lint enforcement in an iOS/macOS repo.
---

# Pre-Commit Hooks for Swift

Format and lint staged Swift on commit, fast enough that nobody disables it.

The web equivalent of this is Husky plus lint-staged plus Prettier. Swift needs
none of that: a plain git hook and two Homebrew-installable tools do the job with
no Node toolchain in an Xcode repo.

## What this sets up

- **SwiftFormat** — rewrites staged Swift files
- **SwiftLint** — fails the commit on real violations
- `.swiftformat` and `.swiftlint.yml` if missing
- A `.git/hooks/pre-commit` that only ever looks at **staged** files

## Steps

### 1. Detect what's already there

```bash
ls .swiftformat .swiftlint.yml .git/hooks/pre-commit 2>/dev/null; command -v swiftformat swiftlint
```

Also check `Package.swift` for the SPM plugin form and `Mintfile`/`Brewfile` for
a pinned version. **Respect whatever the repo already pins** — a hook that runs a
different SwiftFormat version than CI will fight the team on every commit.

### 2. Install the tools

```bash
brew install swiftformat swiftlint
```

For a version-pinned team setup, prefer Mint (`mint install nicklockwood/SwiftFormat@0.57.2`)
or the SPM plugin, and call that binary from the hook instead.

### 3. Write `.git/hooks/pre-commit`

```bash
#!/bin/bash
set -euo pipefail

# Only staged Swift files, and only ones that still exist.
files=$(git diff --cached --name-only --diff-filter=ACMR -- '*.swift')
[ -z "$files" ] && exit 0

if command -v swiftformat >/dev/null; then
  echo "$files" | tr '\n' '\0' | xargs -0 swiftformat --quiet
  echo "$files" | tr '\n' '\0' | xargs -0 git add
fi

if command -v swiftlint >/dev/null; then
  echo "$files" | tr '\n' '\0' | xargs -0 swiftlint lint --quiet --strict -- || {
    echo "✗ SwiftLint failed. Fix the violations above, or commit with --no-verify."
    exit 1
  }
fi
```

```bash
chmod +x .git/hooks/pre-commit
```

Three details that matter:

- **`--diff-filter=ACMR`** skips deleted files. Without it the hook crashes on any
  commit that removes a Swift file.
- **`git add` after formatting** re-stages the rewrite. Without it, the formatted
  version stays in the working tree and the *unformatted* version gets committed.
- **Staged files only.** Linting the whole repo on every commit is how hooks get
  disabled.

### 4. Configure the tools

`.swiftformat` — only if none exists:

```
--swiftversion 6.0
--indent 4
--maxwidth 120
--wraparguments before-first
--wrapparameters before-first
--stripunusedargs closure-only
--exclude .build,Pods,Derived,**/*.generated.swift
```

`.swiftlint.yml` — only if none exists:

```yaml
excluded:
  - .build
  - Pods
  - Derived
  - "**/*.generated.swift"

opt_in_rules:
  - empty_count
  - force_unwrapping
  - redundant_nil_coalescing
  - unowned_variable_capture

line_length:
  warning: 120
  error: 200

identifier_name:
  excluded: [id, ok, no, up, x, y, z]
```

`identifier_name` needs that exclusion list in practice — SwiftLint flags short
names by default and `id` appears constantly in Swift code.

### 5. Share it with the team

`.git/hooks/` is **not** version controlled, so the above only helps you. To make
it everyone's:

```bash
mkdir -p .githooks && mv .git/hooks/pre-commit .githooks/pre-commit
```

```bash
git config core.hooksPath .githooks
```

Commit `.githooks/`, and add the `git config` line to the repo's setup docs — it
must be run once per clone. This is the step most guides omit, and it's why "we
have hooks" so often means "one person has hooks".

### 6. Verify

- [ ] `.githooks/pre-commit` exists and is executable (`git update-index --chmod=+x`)
- [ ] `core.hooksPath` is set
- [ ] Deliberately mis-format a file, stage it, commit — it should be reformatted
      and committed correctly
- [ ] Stage a `force_unwrapping` violation — the commit should be **rejected**
- [ ] Commit with no Swift files staged — the hook should exit 0 immediately

### 7. Commit

```bash
git add .githooks .swiftformat .swiftlint.yml && git commit -m "Add SwiftFormat/SwiftLint pre-commit hooks"
```

Which itself runs the hook — a good smoke test.

## Notes

- **Don't put SwiftLint in an Xcode build phase as well.** Linting on every build
  is slow and duplicates the hook; keep it at commit time and in CI.
- CI must run the same versions, or the hook and the pipeline will disagree.
- `--no-verify` exists deliberately. A hook that can't be bypassed in an
  emergency gets deleted instead.

---

*Structure adapted from [`mattpocock/skills`](https://github.com/mattpocock/skills)
(`misc/setup-pre-commit`), MIT © Matt Pocock. The Husky/lint-staged/Prettier toolchain
does not apply to Swift, so the implementation here is new. Full license in [NOTICE.md](NOTICE.md).*
