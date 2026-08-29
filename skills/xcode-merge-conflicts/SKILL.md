---
name: xcode-merge-conflicts
description: Resolve in-progress git merge or rebase conflicts in an Xcode project, including project.pbxproj, xcworkspace, Package.resolved, xcscheme, String Catalogs, asset catalogs, and Core Data models. Use when a merge or rebase has stopped with conflicts in an iOS/macOS repo.
---

# Resolving Xcode Merge Conflicts

Ordinary Swift files merge like any other source. The generated files Xcode owns
do not — and resolving those by hand, wrongly, is how a project ends up with
duplicate build phases, files missing from targets, or a `.pbxproj` that opens
but silently drops a compile unit.

## 1. See the current state

```bash
git status --short && git diff --name-only --diff-filter=U
```

Sort the conflicted paths into two buckets, because they need opposite tactics:

| Bucket | Paths | Tactic |
|---|---|---|
| **Hand-written** | `*.swift`, `*.h/m`, `*.md`, `*.yml`, `Package.swift` | Read both sides, merge intents |
| **Tool-owned** | `project.pbxproj`, `*.xcworkspace/*`, `*.xcscheme`, `Package.resolved`, `*.xcstrings`, `Contents.json`, `*.xcdatamodeld` | Prefer regeneration over hand-editing |

## 2. Understand why each change was made

For hand-written conflicts, read the commit messages, the PR, and the originating
issue on both sides before touching a hunk. Preserve both intents where possible;
where they're incompatible, pick the one matching the merge's stated goal and say
what you traded away. **Never invent new behavior in a conflict resolution.**

## 3. Resolve the tool-owned files

### `project.pbxproj`

The single most common conflict, and the one most often resolved wrong.

- Conflicts are usually **both sides adding a file** — two new `PBXBuildFile` and
  `PBXFileReference` entries landing at the same spot. The correct resolution is
  almost always **keep both sides**, then verify.
- Each file added to a target appears in **several sections** (`PBXBuildFile`,
  `PBXFileReference`, `PBXGroup` children, and the target's `PBXSourcesBuildPhase`).
  Keeping a hunk in one section and dropping it in another produces a project
  that opens fine and fails to compile the file, or worse, compiles it into only
  one of two targets.
- The 24-character hex IDs must stay internally consistent. Never hand-write a
  new one; never renumber.

```bash
git checkout --ours  App.xcodeproj/project.pbxproj   # then re-add your files in Xcode
```

When both sides changed build settings rather than file membership, taking
`--ours` and redoing the other side's setting change in Xcode is faster and far
safer than merging the hunks by hand.

**Always verify structurally before trusting it:**

```bash
plutil -lint App.xcodeproj/project.pbxproj
```

```bash
xcodebuild -list -project App.xcodeproj
```

Then confirm file membership actually survived:

```bash
xcodebuild -project App.xcodeproj -target App -showBuildSettings >/dev/null && echo "project parses"
```

A `.pbxproj` that passes `plutil -lint` can still be semantically wrong, so
finish by building — not just opening — the project.

> If the repo uses **Tuist** or **XcodeGen**, the `.pbxproj` is generated output.
> Resolve `Project.swift` / `project.yml` instead and regenerate:
> `tuist generate` or `xcodegen generate`. Never hand-merge generated output when
> the generator input is under version control.

### `Package.resolved`

Never merge by hand. Take either side and re-resolve so the graph is internally
consistent:

```bash
git checkout --theirs App.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved
```

```bash
xcodebuild -resolvePackageDependencies -project App.xcodeproj
```

A hand-merged `Package.resolved` can pin a revision that doesn't satisfy the
`Package.swift` constraints — it resolves cleanly on your machine and fails in CI.

### `*.xcstrings` (String Catalogs)

JSON, so it merges structurally, but conflicts usually mean both sides added keys.
Keep both sides, then confirm the file still parses and no key lost a language:

```bash
plutil -lint Localizable.xcstrings
```

Watch for `extractionState` flipping between `manual` and `extracted_with_value` —
take the side that matches how the string is actually declared in code.

### `*.xcscheme`

Shared schemes conflict on test targets and launch arguments. These are cheap to
rebuild: take one side, then reapply the other's change through Xcode's scheme
editor. Confirm with:

```bash
xcodebuild -list -project App.xcodeproj | sed -n '/Schemes/,$p'
```

### Asset catalogs

`Contents.json` conflicts are almost always additive — keep both sides. If two
branches added **different images under the same asset name**, that's a real
conflict: pick one and rename the other, because the catalog can't hold both.

### `*.xcdatamodeld`

Conflicting edits to the *same* model version are dangerous — a wrong merge
corrupts the store for users who already migrated. Prefer taking one side whole
and re-applying the other's entity changes in the model editor. If both sides
added a new model version, keep both and confirm `.xccurrentversion` points at
the intended one.

## 4. Run the project's checks

Discover and run them in this order — cheapest signal first:

```bash
swift build 2>&1 | tail -20
```

```bash
xcodebuild build -scheme App -destination 'generic/platform=iOS' -quiet
```

```bash
xcodebuild test -scheme App -destination 'platform=iOS Simulator,name=iPhone 17' -quiet
```

Then formatting/linting if the repo has it (`swiftformat --lint .`,
`swiftlint --strict`).

A merge that compiles is not a merge that worked: run the tests. `.pbxproj`
mistakes very often surface as "a test target lost a file" rather than a build
error.

## 5. Finish

Stage everything and complete the operation. **Always resolve; never `--abort`**
once you've started reasoning about the hunks.

```bash
git add -A && git commit --no-edit
```

```bash
git rebase --continue
```

If rebasing, expect the same `.pbxproj` conflict to recur on each replayed
commit. That repetition is a signal: consider `git rerere`, or rebase with a
merge strategy that keeps the project file from a single side and regenerate at
the end.

---

*Adapted for Xcode from [`mattpocock/skills`](https://github.com/mattpocock/skills)
(`engineering/resolving-merge-conflicts`), MIT © Matt Pocock. The five-step frame is
his; the Xcode file-type handling is new. Full license in [NOTICE.md](NOTICE.md).*
