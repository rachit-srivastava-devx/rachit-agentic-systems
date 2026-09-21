# Section-by-Section Guide

Detailed instructions for each of the 12 sections. Read the relevant section before writing or editing it — table columns and ID conventions are exact.

## Contents

1. [Document Meta](#section-1--document-meta)
2. [Client & Business Context](#section-2--client--business-context)
3. [Current System Landscape](#section-3--current-system-landscape)
4. [Consolidated Pain Points](#section-4--consolidated-pain-points)
5. [Industry Benchmarks](#section-5--industry-benchmarks)
6. [Architectural Principles](#section-6--architectural-principles)
7. [Solution Architecture](#section-7--solution-architecture)
8. [Module-by-Module Solutions](#section-8--module-by-module-solution-mapping)
9. [Traceability Matrix](#section-9--traceability-matrix)
10. [Open Questions & Assumptions](#section-10--open-questions--assumptions)
11. [Decision Log](#section-11--decision-log)
12. [Appendices](#section-12--appendices)

---

## Section 1 — Document Meta

**Purpose:** Orientation layer. Tells anyone who opens this doc what it is, how to use it, what version it's at, and what terms mean.

**1.1 Status table** (Notion table)
Columns: `Project` | `Version` | `Last Updated` | `Owner` | `Stage`
- Version starts at `0.1` and bumps at each stage completion or major revision
- Stage is one of: Discovery / Draft / Validated / In Development / Live
- Owner is typically "devx Labs"

**1.2 How to Use This Doc**
4–6 bullets: what the doc exists to do, who the audience is, the split between internal and client-facing sections, what drives version bumps.

**1.3 Section Status Table**
One row per section. Status column uses: `✅ Draft` / `🔄 In Progress` / `❌ Not Started` / `🔒 Validated`.

**1.4 Update Protocol**
Short bullet list: what happens after each discovery call (add PPs, add Qs, mark Qs answered); what triggers a version bump; what happens before client design reviews.

**1.5 Working Glossary**
Notion table `Term` | `Definition`. Include every project-specific term (product names, roles, abbreviations) as soon as encountered. Grows throughout.

---

## Section 2 — Client & Business Context

**Purpose:** Shared understanding of who the client is before proposing anything.

**2.1 Who the Client Is**
2–3 paragraphs: founding story, scale signals (revenue, stores, users, growth — public or client-shared data), product portfolio, market position. Include a `> [!note]` callout with framing that shapes how we approach the engagement.

**2.2 Product Portfolio**
Notion table, one row per product type/tier. Columns: `Type` | `Description` | `Inventory Model` | `TAT or Delivery Speed` | `Customization Level`. Every row should represent a meaningfully different workflow for the system being built.

**2.3 Business Model**
Short prose: how the client makes money, channels (online/offline/wholesale), production model (in-house factory, third-party, etc.).

**2.4 Proposed Customer Journey**
A code block (plain indented ASCII, **not** Mermaid) showing end-to-end journey from customer arrival to post-sale. Fork at branch points (e.g. RTW vs Custom). This is the journey the system will support, not necessarily today's.

**2.5 Current Data Flow (As-Is)**
Numbered list of how data moves today, first touchpoint to order completion. Be honest — include paper diaries, WhatsApp, Excel. "(to be confirmed with client)" notes are fine.

---

## Section 3 — Current System Landscape

**Purpose:** Map what exists today. Strictly descriptive.

**3.1 System Inventory**
Notion table. Columns: `System` | `Role today` | `Pain points it creates`. One row per tool (POS, CRM, ERP, spreadsheets, messaging tools, barcode scanners, manual diaries). Cross-reference "see Section 4" where relevant.

**3.2 Where Manual Workarounds Live**
Prose + short bullet lists in 3 categories: Data capture workarounds / Communication workarounds / Approval workarounds. Every workaround named here should have a corresponding pain point in Section 4.

---

## Section 4 — Consolidated Pain Points

**Purpose:** The single most important section for scoping. Every feature devx builds should trace back to at least one pain point here.

**Conventions:**
- **Pain Point ID format:** `PP-{THEME_CODE}-{NUMBER}` e.g. `PP-WB-01`
- **Theme codes:** 2-letter codes per theme
- **Severity:** `Critical` = blocks revenue or creates customer-facing failure today / `High` = operational friction compounding at scale / `Medium` = inefficiency without immediate business risk
- **Status:** `Validated` = client confirmed in a MoM / `Assumed` = inferred from context / `Needs clarification` = see Section 10
- Never add a pain point without an ID — future traceability depends on stable IDs
- If disproven or merged, **don't delete** — mark with `~~strikethrough~~` and a note explaining what happened

**4.1 Customer-Facing Summary**
3–5 sentence prose describing themes at a human level. What is the business trying to improve? Avoid jargon. Most likely section to be shown to the client.

**4.2 Conventions block**
Short reference block explaining Severity, Status, and Source definitions.

**4.3 Summary by Theme table**
Notion table: `Theme` | `Code` | `Critical` | `High` | `Medium` | `Total`

**4.4 Pain Points by Theme**
One H2 heading per theme. Under each, bullet-list each PP:

```
- **PP-XX-NN** — [Short Title] — `Severity` `Status`
  **Description:** [1–3 sentences. What is happening today? Be specific — name the tool or process that is broken.]
  **Impact:** [1–3 sentences. What does this cost the business? Use numbers — time, money, error rate, customer perception.]
  **Note (optional):** [Qualifier — open question reference, devx observation, client clarification pending.]
```

**Suggested theme structure** (adapt to the project):
- A. Workflow Breaks — where the core operational process fails
- B. Data Silos & Fragmentation — same data in too many places
- C. Inventory & Availability — stock visibility breaks down
- D. Customer Experience Gaps — customer-facing experience underdelivers
- E. Staff & Operational Friction — system creates burden for staff
- F. Post-Sale Process Gaps — returns, refunds, after-service

Adapt themes to the domain. Logistics might have "Route Optimization"; SaaS might have "Multi-tenancy & Permissions."

---

## Section 5 — Industry Benchmarks

> ⚠️ **Internal-only.** Not to be shared with the client in this form.

**Purpose:** Evidence base for architectural decisions. Every entry answers: what does a best-in-class operator do, and what can we take from it?

**5.1 How These Brands Map to the Client**
Notion table: `Brand` | `Why Relevant` | `Pattern We Borrow`

**5.2 One sub-section per benchmark brand**
- **What they do:** 1 paragraph
- **Key data points:** 3–5 bullets with specific metrics (conversion rates, NPS, time savings, revenue impact)
- **What we learn:** 2–4 bullets of actionable patterns
- **Relevance to [client]:** 1 sentence connecting the benchmark to a specific architectural or product decision

Keep each short. The value is the pattern, not the brand story.

---

## Section 6 — Architectural Principles

> ⚠️ **Internal-only.** Not to be shared with the client in this form.

**Purpose:** 6–8 rules that govern every design decision. They are the filter: any proposed solution must pass all principles, or the proposal is wrong, or the principle needs revision. Non-negotiable defaults.

**Format for each principle:**
```
## P{N}. [Principle Name]
[1–2 sentences stating the principle clearly and unambiguously.]

**What this means in practice:**
- [Concrete example 1]
- [Concrete example 2]
- [Concrete example 3]
```

**Good principles to always include (adapt wording):**
- The system should guide the user, not burden them (P1 - Guided Experience)
- Customer data is the long-term asset — capture once, enrich continuously (P2 - Data Moat)
- Clear separation of concerns between systems — no spaghetti integrations (P3 - Three Layers, Three Masters)
- Visible staleness is a bug; hidden staleness is an outage (P4 - Eventually Consistent)
- System constraints beat staff discipline (P5 - No Workarounds)
- User-facing flows never wait on external systems (P6 - Async by Default)
- Design for the worst integration case, upgrade as capability emerges (P7 - Asymmetric Integration)
- The client's premium policies are a feature, not a constraint (P8 - Policy Preserved)

---

## Section 7 — Solution Architecture

> ⚠️ **Internal-only.**

**Purpose:** System-level design before drilling into modules. How do the pieces fit, who owns what data, what does every state machine look like?

**7.1 System Topology**
Mermaid `graph TB` diagram showing all system nodes (devx-built modules + external integrations) and connection types. Add a legend for solid vs dotted lines (real-time vs eventually consistent vs manual/uncertain).

**7.2 Data Ownership Matrix**
Notion table: `Data entity` | `Master (source of truth)` | `Mirrored / Synced To` | `Notes`. Every data entity must have exactly one master. Most important artifact for preventing sync conflicts.

**7.3 Customer Profile Model** *(if applicable — skip for non-consumer projects)*
If there's a customer/user model with multiple data layers, define them:
- Layer 1: Hard/verified data (measurements, certifications, verified attributes)
- Layer 2: Structured preferences (intake-driven, explicitly captured)
- Layer 3: Behavioral data (auto-accrued from system events)

**7.4 Core State Machine(s)**
One Mermaid `stateDiagram-v2` per major workflow. Common ones: Order lifecycle (Cart → Placed → In Production → Shipped → Delivered); Return/refund lifecycle; Alteration or service request lifecycle. Add bullets after each diagram explaining key rules (what triggers transitions, what gates exist, what can/can't be bypassed).

**7.5 Edit Permission Matrix** *(if applicable)*
Notion table: what can be edited at each lifecycle stage. Columns = edit categories; rows = stages. Use ✅ (auto-allowed) / ⚠️ (needs approval) / ❌ (locked). Mark clearly if this is a devx proposal pending client validation.

**7.6 Integration-Specific Architecture** *(add as needed)*
If a complex external integration has multiple possible scenarios (API available vs database read vs no programmatic access), document each with its architectural implications. Use `> [!info]` to flag the confirmed scenario.

**7.7–7.N Additional Sub-sections**
Add domain-specific sections: Communication & Notification Architecture (multi-channel comms), Inventory Model, Alteration/Service Architecture, or any system behavior needing a formal model before module specs.

---

## Section 8 — Module-by-Module Solution Mapping

> ⚠️ **Internal-only.**

**Purpose:** What each module does, which pain points it solves, which principles it embodies. Foundation for workflow diagrams (a separate deliverable).

**8.0 Module Map**
Mermaid diagram showing the modules, who uses them, how they connect.

**One H2 per module** (e.g. "Retail-OS Store", "Retail-OS Backend", "Retail-OS Admin"). For each:
- **Users:** Who interacts with this module
- **Form factor:** Device / platform / context
- **Mental model:** One sentence — the "so that" statement

Then one H3 per capability area, with bullets. Each bullet is a concrete deliverable:
```
- **[Capability name]** — [What it does. Who benefits. Why it matters.]
```

End each module section with:
1. **Pain Points Addressed** — Notion table: `Pain Point` | `How`
2. **Architectural Principles Embodied** — P1–PN references
3. **Module-Specific Open Questions** — 3–5 unresolved questions specific to this module

---

## Section 9 — Traceability Matrix

> ⚠️ **Internal-only.**

**Purpose:** Proof that every pain point is addressed; sanity-check that every capability has a PP justification.

**Format:** Single Notion table. Columns: `PP ID` | `Sev` (C/H/M) | `Title` | `Module(s)` (S/B/A) | `Capability` (8.x.y references) | `Principles` (P1–P8) | `Expected Outcome` (measurable post-launch target)

Every PP from Section 4 must have a row. No PP left unaddressed. Add a coverage sanity-check table at the end: `Module` | `PPs Addressed`.

---

## Section 10 — Open Questions & Assumptions

> ⚠️ **Internal-only.**

**Purpose:** The honest inventory of what we don't know. Drives the agenda for every discovery call. The most important section to maintain in a living document.

**Convention:**
- **Q ID format:** `Q-{CATEGORY}-{NUMBER}` e.g. `Q-EN-01`
- **Category codes:** EN = integration/external systems / EX = Excel/data migration / CO = courier/logistics / CM = communications / PY = payments / AP = business process & policy / SC = scope & phasing / TE = technical stack / DA = data & volume / RO = org & roles / BI = reporting & BI
- **Priority:** P0 = blocks Phase 1 scope / P1 = blocks design detail / P2 = nice to know
- **Status:** Open / In Progress / Answered (with source e.g. "Answered (MoM 4)")

**Table format per category:** `ID` | `Question` | `Status` | `Blocks` | `Priority`

**Always include categories for:** each external system; Business Process & Policy (edit permissions, approval flows, reason codes); Scope & Phasing (Phase 1 vs 2); Technical Stack (versions, hosting, hardware); Data & Volume (order volumes, customer counts, migration scope); Organization & Roles (role granularity, multi-location hierarchy).

End the section with:
1. **Top 10 Priority Questions for Next Client Call** — pull the P0s
2. **Assumptions Locked In** — table: `Assumption` | `Reason for assuming` | `Affected sections`

---

## Section 11 — Decision Log

> ⚠️ **Internal-only.**

**Purpose:** Every meaningful architectural decision, written at the time it was made. Future team members read this to understand *why*, not just *what*.

**Convention:**
- **D ID format:** `D-NN` sequential
- Never delete decisions — if reversed, add a new decision that supersedes it and cross-reference
- Decisions are append-only

**Table format:** `D ID` | `Date` | `Decision` | `Alternatives Considered` | `Rationale`

Good triggers for a decision: choosing one tech over another; resolving a data ownership conflict; confirming or rejecting a client process as-is; answering an open question in a way that changes architecture; expanding or contracting scope.

---

## Section 12 — Appendices

**12.A Expanded Glossary**
Full definitions for domain terms referenced in the doc (beyond the working glossary in Section 1).

**12.B Industry Reference Material**
Bibliographic sources for Section 5 benchmarks.

**12.C Document Maintenance Protocol**
3 procedures as numbered checklists: After every discovery call / Before any client design review / When making architectural decisions.
