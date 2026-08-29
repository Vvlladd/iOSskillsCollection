# Attribution

`swift-pre-commit` is a derivative work of the `setup-pre-commit` skill from
[**mattpocock/skills**](https://github.com/mattpocock/skills) (`misc/setup-pre-commit`), used and
modified under the MIT License.

## What came from upstream

The task structure: detect what exists, install, write the hook, configure, verify with a checklist, commit as a smoke test.

## What was added here

The entire implementation. Husky, lint-staged and Prettier have no role in a Swift repo, so this is a plain git hook driving SwiftFormat and SwiftLint, plus the staged-files-only handling, the re-stage-after-format step, and `core.hooksPath` for sharing hooks with a team.

## Upstream license

```
MIT License

Copyright (c) 2026 Matt Pocock

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

Modifications © 2026 Vlad Toma, released under the same MIT terms.
