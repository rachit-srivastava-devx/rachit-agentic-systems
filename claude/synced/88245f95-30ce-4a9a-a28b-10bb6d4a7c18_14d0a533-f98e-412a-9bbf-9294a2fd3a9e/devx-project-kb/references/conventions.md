# Conventions, Style & Examples

Read this before writing prose-heavy or table-heavy sections so output matches house style.

## Notion Formatting Conventions

| Element | Use |
|---|---|
| `> [!note]` callout | Important framing, context the team needs to internalize |
| `> [!warning]` callout | Internal-only sections, unvalidated proposals |
| `> [!info]` callout | Confirmed decisions, answered questions, positive resolutions |
| `> [!callout]` callout | Stage completion markers (End of Stage 1, etc.) |
| `# Section N` | Top-level section heading (H1) |
| `## Sub-section` | Major sub-section (H2) |
| `### Capability Area` | Module capability areas (H3) |
| Mermaid code blocks | All state machines and topology diagrams |
| Plain indented ASCII | The customer journey in 2.4 (NOT Mermaid) |
| Notion tables | All matrices, logs, inventories |
| Bold lead-in on bullets | `**Lead —** rest of sentence` for structured bullet lists |

Stage completion callouts close each major grouping:
```
> [!callout]
> **End of Stage N.** [What comes next.]
```

## Writing Style

- **Declarative, not weaselly.** "Retail-OS owns measurement data" not "Retail-OS could potentially own measurement data."
- **Specific, not vague.** "Staff WhatsApp other stores to check availability" not "communication is manual."
- **Impact-first for pain points.** Lead with the business cost, not the technical description.
- **Short sentences for architecture.** If a sentence is doing two things, split it.
- **No em dashes in prose.** Use bullet structure instead of packing multiple ideas into one sentence.
- **Numbers where possible.** "~10% of returns are fabric-driven" beats "a significant portion of returns."
- **Internal cynicism is fine.** If the client's current process is bad, say so — this is an internal doc.
- **Never delete, always annotate.** Out-of-date info gets a strikethrough and a note, not a delete.

## What Makes a Good Entry

**Good pain point:**
> PP-WB-01 — POS Forces Payment Before Customization Capture — `Critical` `Validated`
> Description: Shopify POS requires payment before styling details can be entered. Stylists capture styling details on paper diaries or in Slack.
> Impact: Data loss; styling cannot be searched, reported on, or referenced for repeat orders. Customer experience is disjointed. Real risk of mismatch between what was paid for and what was actually built.

**Bad pain point:**
> The payment system is not ideal. Customization is tricky.

---

**Good decision log entry:**
> D-06 | 2026-05 | Cart-before-payment flow using Medusa draft cart pattern | Work around Shopify POS's payment-first constraint | Shopify POS forces payment first. Medusa cart is fully decoupled from payment. This is the architectural unlock for PP-WB-01.

**Bad decision log entry:**
> D-06 | We're using Medusa because it's better.

---

**Good open question:**
> Q-AP-08 | Exhaustive list of custom style attributes from [client] — collar types, button placements, pocket styles, sleeve types, cuff details, monogram options — plus dependency rules (which options are mutually exclusive or co-dependent) | Open | Customization Builder spec | P0

**Bad open question:**
> Q-08 | What are the style options? | Open

## Version History Convention

| Version | What it marks |
|---|---|
| 0.1 | First draft — Sections 1–3 populated |
| 0.2 | Pain points added (Section 4) |
| 0.3 | Architecture drafted (Sections 5–7) |
| 0.4 | Module specs drafted (Section 8) |
| 0.5 | Traceability + open questions + decisions (Sections 9–11) |
| 1.0 | First complete pass — all sections populated |
| 1.x | MoM-driven updates, comment review passes |
| 2.0 | Major architectural revision (scope change, integration confirmed, etc.) |
