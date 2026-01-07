---
title: "Typst x Claude"
description: "Combining Claude Code with Typst for efficient, professional PDF document generation."
date: 2026-01-07
author: ""
og:
  title: "Typst x Claude"
  description: "Combining Claude Code with Typst for efficient, professional PDF document generation."
  type: "article"
  image: "https://richardcocks.github.io/chum/img/typst-claude-header.png"
twitter:
  card: "summary_large_image"
  title: "Typst x Claude"
  description: "Combining Claude Code with Typst for efficient, professional PDF document generation."
  image: "https://richardcocks.github.io/chum/img/typst-claude-header.png"
---

# Typst x Claude

![Typst x Claude](img/typst-claude-header.png)

I've been enjoying using claude for coding, but I've not been enjoying the reams of markdown output. While I find markdown comfortable to write, I find it difficult to read lots of output.

[Typst](https://github.com/typst/typst) to the rescue.

The combination lets claude go wild generating documentation that is much more comfortable to read. Comfortable to read documentation in a familiar format.

Typst is a markup-based typesetting system designed as an alternative to LaTeX[^1]. It features clean syntax, fast compilation, and programmable layouts while maintaining sufficient simplicity for large language models to generate fluently.

Claude seems very good at writing a lot of Typst with minimal errors. It sometimes forgets to escape the \# character, but a few pointers in `CLAUDE.md` fixes that up.

## Implementation

After installing typst, I just have a `/d/dump/docs/` folder that has my font preferences and fixes in a `CLAUDE.md` file, and point it there to generate any documentation.

For example, I asked it to generate a document demonstrating a range of styles, and it generated this [good looking PDF](claude-typst-gallery.pdf).

The source code that it actually wrote is [here](claude-typst-gallery.typ).

---

**Resources:**

- Claude Code: [https://claude.com/claude-code](https://claude.com/claude-code)
- Typst Documentation: [https://typst.app/docs](https://typst.app/docs)
- Typst Download: [https://github.com/typst/typst](https://github.com/typst/typst)