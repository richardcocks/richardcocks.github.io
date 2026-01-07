---
title: "Claude x Typst"
description: "Examples for AI-Assisted Document Generation."
date: 2026-01-07
author: ""
og:
  title: "Claude x Typst"
  description: "Combining Claude Code with Typst for efficient, professional PDF document generation."
  type: "article"
  image: "https://richardcocks.github.io/chum/img/typst-claude-header.png"
twitter:
  card: "summary_large_image"
  title: "Claude x Typst"
  description: "Combining Claude Code with Typst for efficient, professional PDF document generation."
  image: "https://richardcocks.github.io/chum/img/typst-claude-header.png"
---

# Claude x Typst

![Claude x Typst](img/typst-claude-header.png)

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

---

## Addendum: Typst Source Code Examples

Below are the Typst source code snippets for various sections from the example gallery. These demonstrate the syntax Claude generates.

### Document Setup

```typst
#set page(
  paper: "us-letter",
  margin: (x: 1.5in, y: 1in),
  numbering: "1",
)

#set text(
  font: "EB Garamond",
  size: 13pt,
  lang: "en",
)

#set par(
  justify: true,
  leading: 0.65em,
)

#set heading(numbering: "1.1")
```

### Title Page

```typst
#align(center)[
  #v(2in)
  #text(size: 28pt, weight: "bold")[
    Claude + Typst
  ]

  #v(0.5em)
  #text(size: 16pt)[
    Examples for AI-Assisted Document Generation
  ]

  #v(2em)
  #text(size: 13pt)[
    Version 1.0 • #datetime.today().display()
  ]
]

#pagebreak()
```

### Tables with Styling

```typst
// Define alternating row colors
#let row-color(idx) = if calc.odd(idx) { rgb("#f5f5f5") } else { white }

#figure(
  table(
    columns: (auto, 1.2fr, 0.8fr, 0.8fr, 1fr),
    align: (left, left, right, right, center),
    stroke: 0.5pt,
    fill: (x, y) => if y == 0 { rgb("#333333") } else { row-color(y) },
    table.header(
      [#text(fill: white, weight: "bold")[ID]],
      [#text(fill: white, weight: "bold")[Description]],
      [#text(fill: white, weight: "bold")[Units]],
      [#text(fill: white, weight: "bold")[Price]],
      [#text(fill: white, weight: "bold")[Status]],
    ),
    [REQ-001], [User authentication system], [1], [\$25,000], [Complete],
    [REQ-002], [Payment processing gateway], [1], [\$40,000], [In Progress],
    [REQ-003], [Reporting dashboard], [3], [\$15,000], [Planned],
  ),
  caption: [Project requirements and status tracking]
)
```

### Mathematical Content

```typst
// Enable equation numbering
#set math.equation(numbering: "(1)")

// Display equations with labels
$ E = m c^2 $ <einstein>

$ nabla times bold(E) = - (partial bold(B))/(partial t) $ <faraday>

$ nabla dot bold(E) = rho / epsilon_0 $ <gauss>

// Reference equations in text
Einstein's mass-energy equivalence (@einstein) and Maxwell's
equations (@faraday, @gauss) form the foundation of modern physics.
```

### Code Blocks

```typst
The following example demonstrates API client implementation:

\```python
import requests
from typing import Dict, Optional

class APIClient:
    """Client for interacting with the REST API."""

    def __init__(self, base_url: str, api_key: str):
        self.base_url = base_url
        self.headers = {
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json"
        }
\```
```

### Callout Boxes

```typst
#rect(
  width: 100%,
  inset: 15pt,
  fill: rgb("#e8f4f8"),
  stroke: (left: 4pt + rgb("#2196f3")),
)[
  *Note:* This is an informational callout box. Use these to
  highlight important information that deserves special attention.
]

#rect(
  width: 100%,
  inset: 15pt,
  fill: rgb("#fff3cd"),
  stroke: (left: 4pt + rgb("#ffc107")),
)[
  *Warning:* This style indicates cautionary information.
]
```

### Headers and Footers

```typst
#set page(
  header: [
    #set text(9pt)
    #grid(
      columns: (1fr, 1fr),
      align(left)[_Claude + Typst Examples_],
      align(right)[Version 1.0]
    )
    #line(length: 100%, stroke: 0.5pt)
  ],
  footer: [
    #line(length: 100%, stroke: 0.5pt)
    #set text(9pt)
    #grid(
      columns: (1fr, 1fr),
      align(left)[Generated: #datetime.today().display()],
      align(right)[Page #context counter(page).display("1 of 1", both: true)]
    )
  ]
)
```

### Two-Column Layout

```typst
#columns(2)[
  == Abstract

  This section demonstrates multi-column layout capabilities in Typst.
  Two-column formatting is commonly used in academic papers, conference
  proceedings, and technical reports.

  The text flows naturally from one column to the next, maintaining
  proper justification and hyphenation.

  #colbreak()

  == Discussion

  Column breaks can be inserted manually using the colbreak() function
  to control where content splits between columns.
]
```

### Figure Placeholders

```typst
#figure(
  rect(
    width: 80%,
    height: 200pt,
    stroke: 1pt + gray,
    fill: rgb("#f0f0f0"),
  )[
    #align(center + horizon)[
      #text(size: 11pt, fill: gray)[
        [System Architecture Diagram]

        Placeholder for figure content
      ]
    ]
  ],
  caption: [High-level system architecture showing major components]
) <fig-architecture>

// Reference in text
As shown in @fig-architecture, the system follows a three-tier pattern.
```