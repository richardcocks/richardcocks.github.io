// Claude + Typst: Example Gallery
// Professional styling

#set page(
  paper: "us-letter",
  margin: (x: 1.5in, y: 1in),
  numbering: "1",
)

#set text(
  font: "Merriweather 24pt",
  size: 11.5pt,
  lang: "en",
)

#set par(
  justify: true,
  leading: 0.65em,
)

#set heading(numbering: "1.1")

// Title page
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

#outline(
  title: "Table of Contents",
  indent: auto,
)

#pagebreak()

= Introduction

This document demonstrates various Typst document styles and elements through concrete examples. Each section shows a different document type or formatting technique that Claude Code can generate when properly instructed.

= Title Page Variations

== Formal Academic Style

#align(center)[
  #v(1in)
  #text(size: 18pt, weight: "bold")[
    Machine Learning Approaches to Natural Language Processing
  ]

  #v(1em)
  #text(size: 13pt)[
    A Comprehensive Survey
  ]

  #v(2em)
  #text(size: 12pt)[
    Jane M. Researcher, PhD

    Department of Computer Science

    University of Technology
  ]

  #v(2em)
  #text(size: 11pt)[
    January 2026
  ]

  #v(3em)
  #text(size: 11pt, style: "italic")[
    Submitted in partial fulfillment of the requirements

    for the degree of Doctor of Philosophy
  ]
]

#pagebreak()

== Technical Report Style

#align(center)[
  #v(0.5in)
  #rect(
    width: 100%,
    inset: 20pt,
    stroke: 2pt + black,
  )[
    #text(size: 20pt, weight: "bold")[
      System Architecture Specification
    ]

    #v(1em)
    #text(size: 13pt)[
      Document No: ARCH-2026-001

      Revision: 1.2

      Classification: Internal Use Only
    ]
  ]

  #v(2em)
  #grid(
    columns: (1fr, 1fr),
    gutter: 20pt,
    align(left)[
      *Author:* Engineering Team

      *Date:* January 7, 2026

      *Status:* Draft
    ],
    align(left)[
      *Reviewed By:* Architecture Board

      *Approved By:* CTO

      *Next Review:* Q2 2026
    ]
  )
]

#pagebreak()

= Tables and Data

== Basic Comparison Table

#figure(
  table(
    columns: (auto, 1fr, 1fr, 1.2fr),
    align: (left, center, center, left),
    stroke: 0.5pt,
    [*Feature*], [*Solution A*], [*Solution B*], [*Notes*],
    [Performance], [High], [Medium], [Based on benchmark tests],
    [Cost], [\$5,000], [\$12,000], [Annual license],
    [Scalability], [Good], [Excellent], [Horizontal scaling supported],
    [Support], [Community], [Enterprise], [24/7 for Solution B],
    [Learning Curve], [Moderate], [Steep], [Documentation quality varies],
    [Integration], [REST API], [REST + GraphQL], [Both offer webhooks],
  ),
  caption: [Feature comparison between solutions]
)

== Styled Data Table with Alternating Rows

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
    [REQ-004], [Mobile application], [2], [\$60,000], [In Progress],
    [REQ-005], [API rate limiting], [1], [\$8,000], [Complete],
    [REQ-006], [Data export functionality], [1], [\$12,000], [Planned],
  ),
  caption: [Project requirements and status tracking]
)

#pagebreak()

= Code Examples

== Python with Syntax Highlighting

The following example demonstrates API client implementation:

```python
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

    def get_user(self, user_id: int) -> Optional[Dict]:
        """Retrieve user information by ID."""
        response = requests.get(
            f"{self.base_url}/users/{user_id}",
            headers=self.headers
        )

        if response.status_code == 200:
            return response.json()
        return None
```

== JSON Configuration Example

```json
{
  "server": {
    "host": "0.0.0.0",
    "port": 8080,
    "workers": 4
  },
  "database": {
    "type": "postgresql",
    "host": "localhost",
    "port": 5432,
    "name": "production_db",
    "pool_size": 20
  },
  "logging": {
    "level": "INFO",
    "format": "json",
    "output": "/var/log/app.log"
  }
}
```

#pagebreak()

= Mathematical Content

== Inline Mathematics

The quadratic formula states that for $a x^2 + b x + c = 0$, the solutions are given by $x = (-b plus.minus sqrt(b^2 - 4a c))/(2a)$, where $a != 0$.

The fundamental theorem of calculus relates differentiation and integration: if $f$ is continuous on $[a, b]$, then $integral_a^b f(x) dif x = F(b) - F(a)$ where $F'(x) = f(x)$.

== Display Equations

The normal distribution probability density function:

$ f(x | mu, sigma^2) = 1/(sqrt(2 pi sigma^2)) e^(-(x - mu)^2 / (2 sigma^2)) $

Euler's identity, considered one of the most beautiful equations in mathematics:

$ e^(i pi) + 1 = 0 $

The Taylor series expansion of a function $f(x)$ about point $a$:

$ f(x) = f(a) + f'(a)(x-a) + (f''(a))/(2!)(x-a)^2 + (f'''(a))/(3!)(x-a)^3 + ... $

== Numbered Equations

#set math.equation(numbering: "(1)")

$ E = m c^2 $ <einstein>

$ nabla times bold(E) = - (partial bold(B))/(partial t) $ <faraday>

$ nabla dot bold(E) = rho / epsilon_0 $ <gauss>

Einstein's mass-energy equivalence (@einstein) and Maxwell's equations (@faraday, @gauss) form the foundation of modern physics.

#pagebreak()

= Lists and Structured Content

== Nested Bullet Lists

Project deliverables include:

- Phase 1: Foundation
  - Infrastructure setup
    - Cloud environment configuration
    - CI/CD pipeline establishment
    - Monitoring and logging systems
  - Core architecture
    - Database schema design
    - API specification
    - Authentication framework

- Phase 2: Implementation
  - Backend services
    - User management
    - Payment processing
    - Notification system
  - Frontend development
    - Web application
    - Mobile applications (iOS, Android)
    - Admin dashboard

- Phase 3: Testing and Deployment
  - Quality assurance
  - Performance testing
  - Security audit
  - Production deployment

== Numbered Lists with Descriptions

#enum(
  [*Requirements Gathering*: Conduct stakeholder interviews and document functional and non-functional requirements. Establish acceptance criteria for each feature.],

  [*System Design*: Create architectural diagrams, define data models, and specify API contracts. Review with technical team for feasibility.],

  [*Implementation*: Develop features according to specification using iterative development methodology. Conduct code reviews and maintain test coverage above 80%.],

  [*Testing and Validation*: Execute comprehensive test plans including unit, integration, and end-to-end testing. Validate against original requirements.],

  [*Deployment and Monitoring*: Deploy to production environment with zero-downtime strategy. Implement monitoring and alerting for key metrics.],
)

#pagebreak()

= Two-Column Layout

#columns(2)[
  == Abstract

  This section demonstrates multi-column layout capabilities in Typst. Two-column formatting is commonly used in academic papers, conference proceedings, and technical reports to maximize page space utilization.

  The text flows naturally from one column to the next, maintaining proper justification and hyphenation. Headers, figures, and equations can span multiple columns when needed.

  == Introduction

  Multi-column layouts present unique typesetting challenges. Text must flow smoothly between columns while maintaining readability. Line lengths should be appropriate for the font size to prevent awkward breaks.

  Typst handles these requirements automatically, adjusting spacing and breaks to produce professional results. Column balancing ensures even distribution of content across the page.

  == Methodology

  The approach taken in this document prioritizes clarity and reproducibility. Each example demonstrates a specific capability with sufficient detail for readers to replicate the results.

  Examples progress from simple to complex, building understanding incrementally. Code snippets include complete context rather than isolated fragments.

  == Results

  The combination of Claude Code and Typst enables rapid generation of professionally formatted documents. Users report significant time savings compared to traditional LaTeX workflows.

  Quality of output matches or exceeds hand-crafted alternatives for most document types. The iterative refinement process allows for progressive enhancement without starting over.

  #colbreak()

  == Discussion

  Several factors contribute to the effectiveness of this approach. Natural language instructions lower the barrier to entry for document creation. The fast compilation cycle enables immediate feedback.

  Typst's modern syntax reduces cognitive load compared to LaTeX. Common operations require less boilerplate and are more intuitive to specify.

  == Conclusion

  AI-assisted document generation represents a meaningful improvement in productivity for technical writing tasks. The workflow demonstrated here combines the best aspects of markup-based typesetting with conversational interaction.

  Future work should explore additional document types and styling variations. Integration with existing documentation pipelines would further enhance utility.
]

#pagebreak()

= Figures and Captions

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
  caption: [High-level system architecture showing major components and data flows]
) <fig-architecture>

#figure(
  rect(
    width: 70%,
    height: 180pt,
    stroke: 1pt + gray,
    fill: rgb("#f0f0f0"),
  )[
    #align(center + horizon)[
      #text(size: 11pt, fill: gray)[
        [Performance Benchmark Results]

        Placeholder for chart or graph
      ]
    ]
  ],
  caption: [Response time measurements under varying load conditions]
) <fig-performance>

As shown in @fig-architecture, the system follows a three-tier architecture pattern. Performance characteristics (@fig-performance) indicate linear scaling up to 10,000 concurrent users.

#pagebreak()

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

= Headers and Footers

This page and subsequent pages demonstrate custom headers and footers. The header shows the document title and version number, while the footer includes generation date and page numbering.

Headers and footers provide consistent navigation elements throughout longer documents. They can include document metadata, chapter titles, page numbers, or other contextual information.

= Callout Boxes and Highlights

#rect(
  width: 100%,
  inset: 15pt,
  fill: rgb("#e8f4f8"),
  stroke: (left: 4pt + rgb("#2196f3")),
)[
  *Note:* This is an informational callout box. Use these to highlight important information that deserves special attention from readers.
]

#v(1em)

#rect(
  width: 100%,
  inset: 15pt,
  fill: rgb("#fff3cd"),
  stroke: (left: 4pt + rgb("#ffc107")),
)[
  *Warning:* This style indicates cautionary information. Readers should pay particular attention to warnings to avoid common pitfalls or errors.
]

#v(1em)

#rect(
  width: 100%,
  inset: 15pt,
  fill: rgb("#d4edda"),
  stroke: (left: 4pt + rgb("#28a745")),
)[
  *Tip:* Helpful suggestions or best practices can be formatted this way to stand out from regular body text while maintaining visual hierarchy.
]

#pagebreak()

= Block Quotes

Extended quotations should be formatted as distinct blocks:

#block(
  inset: (left: 30pt, right: 30pt, top: 10pt, bottom: 10pt),
  fill: rgb("#fafafa"),
)[
  #set text(style: "italic")

    1. A robot may not injure a human being or, through inaction, allow a human being to come to harm.
    2. A robot must obey the orders given it by human beings except where such orders would conflict with the First Law.
    3. A robot must protect its own existence as long as such protection does not conflict with the First or Second Law.

  #align(right)[
    #text(style: "normal")[— Handbook of Robotics, 56th Edition, 2058 A.D]
  ]
]

Shorter inline quotations can use standard formatting: "It is only afterward that a new idea seems reasonable. To begin with, it usually seems unreasonable." - also Isaac Asimov.

= Footnotes and Endnotes

Typst supports footnotes for supplementary information.#footnote[This is an example footnote providing additional context without disrupting main text flow.] Footnotes appear at the bottom of the page where they are referenced.

Multiple footnotes#footnote[First footnote on this topic.] can appear in close proximity#footnote[Second related footnote with additional details.] without causing layout issues. The system handles numbering and positioning automatically.

#pagebreak()

= Meeting Minutes Template

#align(center)[
  #text(size: 16pt, weight: "bold")[Engineering Team Meeting]

  #text(size: 12pt)[January 7, 2026 • 2:00 PM – 3:00 PM]
]

#v(1em)

*Attendees:* Sarah Johnson (Chair), Michael Chen, Emma Williams, David Rodriguez, Lisa Thompson

*Absent:* None

*Location:* Conference Room B / Zoom

#v(1em)

== Agenda Items

=== 1. Project Status Updates

*Discussion:* Each team member provided updates on their current work streams. The authentication service is on track for next week's release. Frontend team encountered styling issues with the new dashboard.

*Action Items:*
- Emma to resolve CSS conflicts in dashboard by January 10 (Owner: Emma)
- Michael to complete API documentation review (Owner: Michael)

=== 2. Q1 Planning

*Discussion:* Reviewed proposed features for Q1 roadmap. Team consensus on prioritizing performance improvements over new features in February. March timeline appears aggressive given current velocity.

*Decisions:*
- Approved performance optimization sprint for February
- Deferred mobile app enhancements to Q2
- Increased testing coverage requirement to 85%

*Action Items:*
- Sarah to update roadmap and share with stakeholders by EOW (Owner: Sarah)
- David to prepare performance baseline metrics (Owner: David)

=== 3. Technical Debt Review

*Discussion:* Identified three critical areas requiring attention: database query optimization, outdated dependencies, and inconsistent error handling across services.

*Action Items:*
- Schedule technical debt reduction sprint for late January (Owner: Sarah)
- Create tickets for dependency upgrades (Owner: Lisa)
- Document error handling standards (Owner: Michael)

== Next Meeting

*Date:* January 14, 2026 at 2:00 PM

*Location:* Conference Room B / Zoom

*Agenda Preview:* Sprint retrospective, Q1 OKR review, architecture decision on caching layer

#pagebreak()

= Request for Proposal (RFP) Format

#align(center)[
  #rect(
    width: 100%,
    inset: 20pt,
    stroke: 1.5pt,
  )[
    #text(size: 18pt, weight: "bold")[
      REQUEST FOR PROPOSAL
    ]

    #v(0.5em)
    #text(size: 14pt)[
      Customer Relationship Management System Implementation
    ]

    #v(1em)
    #text(size: 11pt)[
      RFP Number: 2026-IT-001

      Issue Date: January 7, 2026

      Response Deadline: February 15, 2026, 5:00 PM PST
    ]
  ]
]

#v(2em)

== Executive Summary

Acme Corporation is seeking proposals from qualified vendors to implement a comprehensive Customer Relationship Management (CRM) system. The selected solution must support sales, marketing, and customer service operations for approximately 200 users across three office locations.

== Scope of Work

The vendor shall provide:

1. *Software Licensing:* Cloud-based CRM platform with appropriate user licenses
2. *Implementation Services:* System configuration, data migration, and integration
3. *Training:* Comprehensive end-user and administrator training programs
4. *Support:* Ongoing technical support and maintenance services

== Technical Requirements

=== Functional Requirements

- Contact and account management with custom field support
- Sales pipeline tracking with configurable stages
- Marketing automation including email campaigns and lead scoring
- Customer service ticketing with SLA management
- Reporting and analytics with custom dashboard capabilities
- Mobile access for iOS and Android platforms

=== Integration Requirements

- Bidirectional sync with Microsoft 365
- Integration with existing ERP system (SAP)
- Email integration (Exchange Server)
- Calendar and scheduling integration
- SSO authentication via Active Directory

=== Performance Requirements

- System uptime: 99.9% availability
- Page load time: < 2 seconds under normal load
- Support for 200 concurrent users
- Data retention: 7 years minimum
- Backup frequency: Daily incremental, weekly full

== Proposal Requirements

Vendors must submit proposals including:

#enum(
  [Company background and relevant experience],
  [Proposed solution architecture and technical approach],
  [Implementation timeline with major milestones],
  [Detailed cost breakdown including licensing, implementation, training, and support],
  [References from at least three comparable implementations],
  [Service level agreements and support model],
  [Security and compliance certifications],
)

== Evaluation Criteria

Proposals will be evaluated on:

#table(
  columns: (1fr, auto),
  align: (left, center),
  stroke: 0.5pt,
  [*Criterion*], [*Weight*],
  [Technical capabilities and features], [30%],
  [Implementation approach and timeline], [25%],
  [Total cost of ownership], [20%],
  [Vendor experience and references], [15%],
  [Support and training offerings], [10%],
)

== Submission Instructions

Submit proposals electronically to procurement\@acme.example.com with subject line "RFP 2026-IT-001 Response." Include all required documentation as PDF attachments.

Questions regarding this RFP should be submitted via email by January 21, 2026. Responses will be published to all vendors by January 24, 2026.

#pagebreak()

= Conclusion

This document has presented a range of Typst formatting examples demonstrating capabilities relevant to AI-assisted document generation. From academic papers to business documents, mathematical content to code samples, Typst provides the necessary tools for professional typesetting.

#pagebreak()

= Addendum: Source Code Examples

This section provides the Typst source code for key examples demonstrated throughout this document. These snippets can be referenced when instructing Claude to generate similar elements.

== Document Setup

The initial configuration for page layout, typography, and heading numbering:

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

== Title Page Construction

Creating a centered title page with multiple text sizes and spacing:

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

#pagebreak()

== Styled Tables with Alternating Rows

Tables with custom colors, alignment, and formatting:

```typst
// Define function for alternating row colors
#let row-color(idx) = if calc.odd(idx) {
  rgb("#f5f5f5")
} else {
  white
}

#figure(
  table(
    columns: (auto, 1.2fr, 0.8fr, 0.8fr, 1fr),
    align: (left, left, right, right, center),
    stroke: 0.5pt,
    fill: (x, y) => if y == 0 {
      rgb("#333333")
    } else {
      row-color(y)
    },
    table.header(
      [#text(fill: white, weight: "bold")[ID]],
      [#text(fill: white, weight: "bold")[Description]],
      [#text(fill: white, weight: "bold")[Units]],
      [#text(fill: white, weight: "bold")[Price]],
      [#text(fill: white, weight: "bold")[Status]],
    ),
    [REQ-001], [User authentication], [1], [\$25,000], [Complete],
    [REQ-002], [Payment gateway], [1], [\$40,000], [In Progress],
  ),
  caption: [Project requirements tracking]
)
```

== Mathematical Equations with Numbering

Display equations with labels and cross-references:

```typst
// Enable equation numbering
#set math.equation(numbering: "(1)")

// Create labeled equations
$ E = m c^2 $ <einstein>

$ nabla times bold(E) = - (partial bold(B))/(partial t) $ <faraday>

$ nabla dot bold(E) = rho / epsilon_0 $ <gauss>

// Reference equations in text
Einstein's mass-energy equivalence (@einstein) and
Maxwell's equations (@faraday, @gauss) form the
foundation of modern physics.
```

#pagebreak()

== Code Blocks with Syntax Highlighting

Including code with automatic syntax highlighting:

````typst
The following demonstrates API implementation:

```python
import requests
from typing import Dict, Optional

class APIClient:
    def __init__(self, base_url: str, api_key: str):
        self.base_url = base_url
        self.headers = {
            "Authorization": f"Bearer {api_key}"
        }
```
````

== Callout Boxes with Color Coding

Creating highlighted boxes for notes, warnings, and tips:

```typst
// Information callout
#rect(
  width: 100%,
  inset: 15pt,
  fill: rgb("#e8f4f8"),
  stroke: (left: 4pt + rgb("#2196f3")),
)[
  *Note:* This is an informational callout box.
]

// Warning callout
#rect(
  width: 100%,
  inset: 15pt,
  fill: rgb("#fff3cd"),
  stroke: (left: 4pt + rgb("#ffc107")),
)[
  *Warning:* This indicates cautionary information.
]

// Success/tip callout
#rect(
  width: 100%,
  inset: 15pt,
  fill: rgb("#d4edda"),
  stroke: (left: 4pt + rgb("#28a745")),
)[
  *Tip:* Helpful suggestions can be formatted this way.
]
```

#pagebreak()

== Headers and Footers

Custom page headers and footers with dynamic content:

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
      align(right)[
        Page #context counter(page).display("1 of 1", both: true)
      ]
    )
  ]
)
```

== Two-Column Layout

Multi-column text flow with manual column breaks:

```typst
#columns(2)[
  == Abstract

  This section demonstrates multi-column layout capabilities.
  Text flows naturally from one column to the next.

  #colbreak()

  == Discussion

  Column breaks can be inserted manually using colbreak()
  to control where content splits between columns.
]
```

#pagebreak()

== Figure Placeholders with Cross-References

Creating figure environments with captions and labels:

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
  caption: [
    High-level system architecture showing major
    components and data flows
  ]
) <fig-architecture>

// Reference the figure in text
As shown in @fig-architecture, the system follows
a three-tier architecture pattern.
```

== Block Quotes with Attribution

Formatted quotations with author attribution:

```typst
#block(
  inset: (left: 30pt, right: 30pt, top: 10pt, bottom: 10pt),
  fill: rgb("#fafafa"),
)[
  #set text(style: "italic")

    1. A robot may not injure a human being or, through inaction, allow a human being to come to harm.
    2. A robot must obey the orders given it by human beings except where such orders would conflict with the First Law.
    3. A robot must protect its own existence as long as such protection does not conflict with the First or Second Law.

  #align(right)[
    #text(style: "normal")[— Handbook of Robotics, 56th Edition, 2058 A.D]
  ]
]
```

