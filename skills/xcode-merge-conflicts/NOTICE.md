# Attribution

`xcode-merge-conflicts` is a derivative work of the `resolving-merge-conflicts` skill from
[**mattpocock/skills**](https://github.com/mattpocock/skills) (`engineering/resolving-merge-conflicts`), used and
modified under the MIT License.

## What came from upstream

The five-step frame: see the state, find the primary sources and original intent, resolve preserving both intents without inventing behavior, run the project's checks, finish rather than abort.

## What was added here

Everything Xcode-specific: the hand-written vs tool-owned split, `project.pbxproj` multi-section handling and `plutil -lint` verification, the Tuist/XcodeGen regeneration rule, `Package.resolved` re-resolution, and handling for `.xcstrings`, `.xcscheme`, asset catalogs and `.xcdatamodeld`.

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
