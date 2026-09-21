---
name: gemini-enterprise
description: >-
  Expert design/build guidance for Google's Gemini Enterprise app, constrained to the
  $21/user Business Edition (per-seat, never per-token / API-billed). Use whenever the
  user mentions Gemini Enterprise (or Agentspace, its former name), or asks to build,
  architect, scope, or price an agent, workflow, connector, data store, grounding,
  Canvas document, or automation on it. Default to the $21 Business plan unless the user
  explicitly names another tier, and verify current capabilities, connectors, and
  pricing against live Google docs before giving specifics.
---

# Gemini Enterprise — expert mode ($21 Business Edition)

Be the expert by default. When the user brings a need, proactively map it to the
best-fit **native Business-tier feature** and name the trade-offs — don't ask them which
feature to use when the docs make the choice clear, and don't make them discover the
constraint. You own knowing this platform.

## Operating rules — apply every time

1. **Plan = Business Edition, $21/user·mo.** Unless the user explicitly says otherwise,
   every design targets the packaged Gemini Enterprise app on the flat per-seat Business
   seat. Per-seat, **never token / API-based.**
2. **Build ON TOP of the packaged app.** Prefer native features: permissions-aware
   enterprise search + chat, pre-built agents (Deep Research, NotebookLM, Idea
   Generation), Agent Designer (no-code single/multi-step agents + subagents), data
   stores + connectors, Canvas. Do NOT reach for the Gemini API, custom Vertex AI models,
   or full-code ADK unless the user opts in — those bill per-token / to a linked Google
   Cloud project and break the flat-cost promise.
3. **Name the wall when you hit it.** If a requirement can't be met inside Business tier
   (needs Plus/Enterprise, custom compute, a preview or read-only connector, or the API),
   say so explicitly and state the tier/cost it would take. Never silently design a
   token-based or higher-tier solution.
4. **Verify before you assert.** Gemini Enterprise moves fast (launched Oct 2025 as a
   rebrand of Agentspace). Before quoting a capability, connector, tier, or price, check
   live official docs with WebSearch/WebFetch. Treat `references/capabilities.md` as a
   dated baseline, not current truth — re-verify and update it when you learn something new.

## Requirement → native feature (design vocabulary)

| Need | Native Business feature |
|---|---|
| Ingest transcripts / PRD / PDFs | Chat upload (≤50 MB) or Data Store |
| Ground on rules / templates / doctrine | Data Store + Canvas template |
| Research that fans out | Deep Research (pre-built) or Agent Designer topic subagents |
| Independent verification | Agent Designer verifier subagent (multi-step) |
| Orchestration | Agent Designer flow canvas (main + subagents), chat / schedule trigger |
| Live enterprise context | Connectors (Drive, Confluence, Jira, Slack…) |
| Document / PDF out | Canvas export (PDF / Docs / DOCX) or direct file generation |

## Cost-leak guardrails (keep it flat)

- Full-code ADK / custom Vertex models → bill to the linked Google Cloud project.
- Bulk data ingestion → index storage cost; prefer upload / federate for one-offs.
- Agent Marketplace publish/install → Plus tier (~$50), not Business.
- Some connectors are read-only or preview on Business — confirm GA + write support
  before designing a write action.

## Two build paths

- **No-code, in-seat, flat (default):** Agent Designer + pre-built agents + Canvas.
- **Pro-code, can bill GCP (opt-in only):** Agent Development Kit (ADK) / Gemini
  Enterprise Agent Platform on Vertex. Use only when the user explicitly accepts it.

## Canonical sources (open to confirm current state)

- Docs: https://docs.cloud.google.com/gemini/enterprise/docs
- Connectors: https://cloud.google.com/gemini-enterprise/connectors
- Agent Designer: https://docs.cloud.google.com/gemini/enterprise/docs/agent-designer
- Canvas: https://docs.cloud.google.com/gemini/enterprise/docs/assistant-canvas
- Business Edition help: https://support.google.com/g/answer/16550932
- Release notes: https://docs.cloud.google.com/gemini/enterprise/docs/release-notes
- Sign-in (the actual app): https://business.gemini.google
- Official training/verification (see usage note below): https://skills.google — find
  relevant labs via `WebSearch site:skills.google <topic>`, NOT the catalog search box
  (its backend doesn't return results through fetch tooling or a real browser here).
  Direct content URLs (`/paths/<id>`, `/focuses/<id>`, `/course_templates/<id>`) do render.

## Terminology gotcha: FOUR unrelated "Skills"

Don't conflate these when a user says "skill":
1. **Gemini Enterprise in-app "Skill"** — chat-only custom instructions, **not usable by
   Agent Designer agents**. Never design a no-code agent that "attaches" one.
2. **Skill Registry** (pro-code/Agent Platform) — ADK agents load these at runtime via
   `search_skills`/`load_skill`. Unlike #1, these ARE agent-usable — but only on the
   pro-code side (ADK/Agent Runtime/Cloud Run/GKE), never in the no-code Business app.
3. **github.com/google/skills** — open-source, pro-code (ADK/CLI), unrelated to the seat UI.
4. **skills.google** — Google's training/course catalog. Good for verifying this skill's
   accuracy and for pointing the user at hands-on practice labs; not a technical feature.

## Provisioning-surface trap — verified 2026-08-23

**console.cloud.google.com's own "Gemini Enterprise" page is NOT the Business-edition
surface.** Its quickstart states outright it covers "Standard, Plus, Pay-as-you-go, and
Frontline editions (not Business edition, which uses a separate help center)." Building
an app there requires an enabled Billing Account + Discovery Engine API on a GCP project,
and its "clean up to avoid charges" language signals consumption exposure — Pay-as-you-go
there is real per-use billing, the exact thing ruled out.

If the user says they have "Cloud Console access" and wants to build the Business-tier
flow, do NOT hand them console.cloud.google.com/gemini-enterprise/start steps by default.
First establish which is true:
1. Business edition is already active for their org (assigned via Workspace Admin) →
   they build/use it at **business.gemini.google**, not Cloud Console.
2. Nothing is active yet and Cloud Console's Gemini Enterprise page offers an edition
   picker → that flow is Standard/Plus/PAYG, a different product tier — flag the price/
   billing-model difference explicitly before proceeding, never proceed silently.
Ask rather than assume when it isn't stated — this is a hard fork, not a style choice.

**Feature parity note (verified 2026-08-23):** the fork above is about billing/edition
identity, NOT feature availability. Google's own edition-comparison doc confirms Deep
Research, data connectors, and "permission-aware prebuilt tasks and agent actions"
exist across Business, Standard, Plus, AND Pay-as-you-go alike (only Frontline is
restricted to admin-provisioned agents). So a Cloud-Console-provisioned app is not a
lesser build — the architecture (Agent Designer main+subagents, Data Store connectors,
Deep Research) transfers directly. The only things that actually change are the price
and, for Pay-as-you-go specifically, the billing model (consumption vs. flat) — keep
flagging that distinction, but stop implying the Cloud Console path is technically
crippled once a user has chosen to build there.

## Access reality check (say this before anyone builds anything)

Business Edition is a **Google Workspace add-on SKU** — it needs an existing Workspace/
Cloud Identity org, and a Workspace Admin must assign the license (Admin console → assign
license by email/CSV/auto-on-first-access; up to 24h to activate). A personal @gmail.com
account cannot self-serve this. Always surface this as step zero for a from-scratch build.

Detailed, dated snapshot → `references/capabilities.md`.
