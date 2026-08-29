# Attribution

`swift-diagnosing-bugs` is a derivative work of the `diagnosing-bugs` skill from
[**mattpocock/skills**](https://github.com/mattpocock/skills) (`engineering/diagnosing-bugs`), used and
modified under the MIT License.

## What came from upstream

The six-phase structure, the insistence that building a tight feedback loop *is* the skill, loop-tightening criteria, ranked falsifiable hypotheses, one-variable-at-a-time instrumentation with tagged debug logs, and the correct-seam rule for regression tests. Several passages are lightly edited from the original prose.

## What was added here

The ten iOS ways to construct a loop (XCTest, SwiftUI previews, `simctl`, LLDB breakpoint actions, `os_log`, Instruments, sanitizers, `git bisect run`); Apple-specific determinism traps; the crash-log termination-reason table; and the memory and performance instrumentation branches.

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
