# Attribution

`swift-code-review` is a derivative work of the `code-review` skill from
[**mattpocock/skills**](https://github.com/mattpocock/skills) (`engineering/code-review`), used and
modified under the MIT License.

## What came from upstream

The two-axis Standards/Spec structure, pinning a fixed point with a three-dot diff and validating it before proceeding, the repo-overrides rule, skipping what tooling already enforces, and the Fowler smell baseline from *Refactoring* ch. 3.

## What was added here

The Swift review baseline: correctness and safety (force unwraps, retain cycles, main-thread violations, unsafe concurrency escapes), API design, SwiftUI-specific criteria, and test criteria. His version reads `docs/agents/issue-tracker.md` produced by his setup skill; that dependency is removed here.

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
