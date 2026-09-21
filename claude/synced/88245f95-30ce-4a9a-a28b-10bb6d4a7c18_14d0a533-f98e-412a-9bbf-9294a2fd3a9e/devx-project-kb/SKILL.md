---
name: devx-project-kb
description: Build and maintain a devx project knowledge base — the single internal Notion source of truth for a software engagement, from first discovery call through delivery. It consolidates client context, pain points, architecture decisions, and open questions in one structured 12-section document. Use this skill whenever the user wants to start a new project KB, scaffold project documentation from discovery calls or MoMs (Minutes of Meeting), add or update pain points, log an architectural decision, capture open questions, write up solution architecture or module specs, or otherwise build out internal project documentation for a client engagement at devx. Trigger it even when the user just says things like "set up the KB for [client]", "turn these meeting notes into the project doc", "add a pain point", "log this decision", or "update the open questions" — the structure and conventions live here and should be applied consistently.
---

# devx Project Knowledge Base

This skill produces and maintains a **single Notion page** that is the internal source of truth for a devx software engagement. It consolidates client context, current-system landscape, pain points, industry benchmarks, solution architecture, module specs, traceability, open questions, and decisions into one searchable, consistently-formatted document.

**Audience:** Internal devx team. Sections 1–6 can be lightly adapted into client-facing material; Sections 7–12 are strictly internal. Never share the raw doc with a client.

## When to do what

Figure out where the user is and jump in:

- **Starting a new KB** → gather inputs (below), then scaffold Sections 1–4 + 12 first. Build the rest up over discovery calls.
- **Adding to an existing KB** → identify the right section, apply that section's conventions from the reference file, preserve all IDs and existing content.
- **A single targeted edit** (one pain point, one decision, one question) → still apply the relevant convention exactly. Stable IDs and append-only logs matter more than speed.

If a Notion connection is available, write directly to the page. Otherwise produce the markdown for the user to paste in.

## Inputs to gather before writing

You need these before scaffolding a new KB. If some are missing, start with what you have and record gaps as open questions in Section 10.

- **MoMs** from all discovery calls
- **Client name**, the product/system devx is building, the primary business problem
- **Current tech stack** the client uses (list everything — even Excel and WhatsApp)
- **Proposed tech stack** devx intends to build on
- **Stakeholder names and roles** (at minimum: client decision-maker, client technical contact, devx lead)
- **Industry reference brands** (2–5 competitors/analogues with documented operational patterns)
- Any **RFP, prior SOW, or scope documents**

## The 12 sections

```
1.  Document Meta            → Who, what version, how to use, glossary
2.  Client & Business Context → Who the client is, their product, business model
3.  Current System Landscape  → What tools they use today and what's broken
4.  Consolidated Pain Points  → Structured list of every problem being solved
5.  Industry Benchmarks       → INTERNAL — reference brands and what we learn
6.  Architectural Principles  → INTERNAL — the 6–8 rules every design must pass
7.  Solution Architecture     → INTERNAL — topology, data ownership, state machines
8.  Module-by-Module Solutions → INTERNAL — what each module does and why
9.  Traceability Matrix       → INTERNAL — every pain point mapped to a module + metric
10. Open Questions & Assumptions → INTERNAL — honest inventory of what we don't know
11. Decision Log              → INTERNAL — every major decision with rationale
12. Appendices                → Glossary expansion, references, maintenance protocol
```

Sections 1–4 and 12 are always required. Sections 5–11 build up over discovery calls — skeletal at first, filled in as knowledge arrives.

The full per-section instructions (sub-sections, table columns, ID formats, exact structures) live in **`references/section-guide.md`**. Read it whenever you're writing or editing any specific section — do not work from memory, because the table columns and ID conventions are exact.

## Build order

Don't write all 12 sections at once. Build forward:

- **Stage 1** (after call 1–2): Sections 1, 2, 3 — context and landscape → version `0.1`
- **Stage 2** (after call 2–3): Section 4 — pain points → `0.2`
- **Stage 3** (after call 3–4): Sections 5, 6, 7 — benchmarks and architecture → `0.3`
- **Stage 4** (after call 4–5): Section 8 — module specs → `0.4`
- **Stage 5** (after call 5+): Sections 9, 10, 11, 12 → `0.5`, then `1.0` at first complete pass

Section 10 (Open Questions) is started on day one and maintained throughout — it's the running list of what you need to ask.

## Core conventions that apply everywhere

These cut across sections. Get them right every time:

- **Stable IDs, never deleted.** Pain points (`PP-XX-NN`), questions (`Q-CAT-NN`), and decisions (`D-NN`) get permanent IDs. If something is disproven, merged, or reversed, **annotate it** (strikethrough + note, or a superseding entry) — never delete. Traceability depends on this.
- **Internal-only sections** (5–11) carry a `> ⚠️ Internal-only.` marker.
- **Impact-first for pain points.** Lead with business cost, then the technical description.
- **Numbers where possible.** "~10% of returns are fabric-driven" beats "a significant portion."
- **Declarative, not weaselly.** "Retail-OS owns measurement data," not "could potentially own."
- **No em dashes in prose.** Split into bullets or short sentences instead.
- **Internal cynicism is fine.** If the client's current process is bad, say so plainly.

See **`references/conventions.md`** for the full Notion formatting table (callout types, heading levels), the writing-style guide, version-history conventions, and worked good/bad examples of pain points, decisions, and open questions. Read it before writing prose-heavy or table-heavy sections so the output matches house style.

## Output format

- **Notion-native.** Use Notion tables for all matrices/logs/inventories, callouts (`> [!note]`, `> [!warning]`, `> [!info]`, `> [!callout]`) per the conventions file, Mermaid code blocks for state machines and topology diagrams, and plain indented ASCII (not Mermaid) for the customer journey in 2.4.
- **Bold lead-in bullets:** `**Lead —** rest of sentence` for structured lists.
- Stage completion markers (`> [!callout] End of Stage N.`) close each major grouping.

## Reference files

- `references/section-guide.md` — Full section-by-section instructions for all 12 sections: sub-sections, table columns, ID formats, required structures, theme/category codes.
- `references/conventions.md` — Notion formatting table, writing style, version history, and good/bad worked examples.
