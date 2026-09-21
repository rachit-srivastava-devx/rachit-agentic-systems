# Gemini Enterprise — capability snapshot

> **Last verified: 2026-08-23** via Google Cloud docs + support pages. Re-verify before
> quoting; connector status and pricing change often. Update this file when you learn
> something newer.

## Editions & pricing (reseller-reported list; annual commitment)

| Edition | ~List price | Notes |
|---|---|---|
| **Business** | **~$21 / user·mo** | ← default target |
| Standard | ~$30 (12-mo) / $35 no-commit | |
| Plus | ~$50 (annual) / $60 | adds full agent Marketplace access |
| Frontline | lighter deskless tier | needs 150 Standard/Plus licenses to activate |

Seat covers the packaged experience (search, chat, pre-built agents, agent builder).
**Custom agent/compute consumption bills separately to the linked Google Cloud account** —
this is the main way to accidentally leave flat pricing.

## What Business Edition includes

- Permissions-aware enterprise search + multimodal chat
- Google connectors: Drive, Gmail, Calendar, Chat, Sites
- 25+ third-party connectors: Jira, Confluence, Slack, MS Teams, Notion, GitHub, HubSpot,
  Linear, Zendesk, Asana, ServiceNow, Dropbox, OneDrive, Outlook, SharePoint… (some read-only)
- File upload ≤50 MB (Outlook 25 MB)
- Pre-built agents (Agent Gallery): Deep Research, NotebookLM, Idea Generation
- Agent Designer: no-code/low-code single + multi-step agents (main agent + subagents),
  flow canvas with Flow / Schedule / Preview tabs, plus a conversational chat pane
- Canvas: create/edit docs & slides; export docs → Google Docs / DOCX / PDF; slides →
  Slides / PPTX / PDF
- Direct file generation: .pdf, .docx, .xlsx, .csv, LaTeX, TXT, RTF, MD
- Data stores: ingestion (indexed) vs federation (live, no copy); MCP tool/server support

## Connector access modes

- **Data ingestion** — copies/indexes into the Gemini Enterprise index. Best search
  quality; uses storage + sync time.
- **Data federation** — queries the source live, no copy. Lower storage, less precision.
- **Actions** — write/act supported on a subset: e.g. SharePoint, Outlook, OneDrive,
  Jira Cloud, Dropbox, ServiceNow.

## Availability caveats seen (verify current)

- GA: Confluence Cloud, Jira Cloud, MS Entra ID, OneDrive / Outlook / SharePoint (ingestion)
- Preview / limited: Salesforce, Box, MS Teams, Slack (federation) — status moving
- Deep Research / NotebookLM run on the latest Gemini models (Gemini 3-class as of early 2026)

## Deep Research (the "fan-out research" primitive)

Pre-built agent: plans a multi-step approach, fans out across many web + enterprise
sources, synthesizes a structured, cited report, and can export straight to Google Docs.

## Access & sign-in (verified 2026-08-23)

- Sign in at **business.gemini.google**.
- Sold as a **Google Workspace add-on SKU** — requires an existing Google Workspace or
  Cloud Identity org. A personal @gmail.com account cannot self-serve this; someone with
  Workspace Admin access must purchase/assign it.
- Admin flow: Admin console → assign "Gemini Enterprise - Business edition" licenses —
  manually by email, via CSV, or auto-assign on first access. **Up to 24h to activate**
  after assignment.
- Team/connector settings live under **Manage team** in the app itself (admin only).

## "Skills" — a DIFFERENT, unrelated feature (don't conflate)

Gemini Enterprise has a literal in-app feature also called **"Skill"** — easy to confuse
with this Claude skill file or with the training site below. Keep them separate:

- **Gemini Enterprise "Skills"** (docs.cloud.google.com/gemini/enterprise/docs/skills):
  a reusable custom-instruction package (`SKILL.md` + optional files/scripts, "open
  skills standard"), created in-app via *Skills → Create skill with Gemini*. Invoked in
  **chat only** via `@`/`/` mention or auto-relevance. **Explicitly NOT usable by Agent
  Designer agents** — do not design an architecture that attaches one to an agent/subagent.
- **github.com/google/skills**: a separate open-source "Agent Skills Repository"
  (Cloud Next 2026) for ADK/Antigravity/Gemini CLI agents, installed via
  `npx skills install`. Pro-code ecosystem, unrelated to the Business seat UI.
- **skills.google**: Google's training/course platform (below) — a third, unrelated
  meaning of "skills" (course completions → skill badges).
- **Skill Registry** (docs.cloud.google.com/gemini-enterprise-agent-platform/build/skill-registry):
  a FOURTH meaning, on the pro-code side. ADK agents call `search_skills`/`load_skill`
  to pull a `SKILL.md`-based package in at runtime as grounding/instructions — this one
  **is agent-usable**, unlike the chat-only in-app "Skill" above. Seen in practice in the
  "[FDE] Build Enterprise Agents" partner.skills.google lab (2026-08-23): a custom ADK
  specialist loads a "using-developer-knowledge-mcp" skill from the Registry to search
  official Google docs. Scope this to pro-code/Agent Platform builds only — it has no
  bearing on the no-code Business-tier design.

## Verified against skills.google (official training) — 2026-08-23

`skills.google/catalog`'s search UI is a client-rendered SPA whose backend didn't return
results through fetch tooling or a real browser here (consistent "Loading… / No results"
regardless of query) — don't retry it as-is. Individual content pages
(`/paths/<id>`, `/focuses/<id>`, `/course_templates/<id>`) render fine; discover them via
`WebSearch site:skills.google <topic>` instead of the catalog search box.

Matched courses that **confirm** this skill's architecture is real and current:

| Course | URL | Confirms |
|---|---|---|
| Introduction to Gemini Enterprise | skills.google/focuses/124709 | Create app → Drive/Cloud Storage/Calendar data stores (OAuth) → pre-built agents → custom agent via **Agent Designer** → **Deep Research** → Gemini Notebook. Uses a "Cymbal Foods" sample case. |
| Create Your First Gemini Enterprise Application | skills.google/course_templates/1586 | Connect data sources → unified search app → deep research agents, multi-agent ideation, Gemini Notebook. |
| **Orchestrate Multi-agent Workflows with Gemini Enterprise** | skills.google/course_templates/1682 | Closest match to a research→verify→compose pipeline: unify 1st/3rd-party data, multi-agent workflows, automate business actions, produce documents — inside the Business-tier app, no ADK. |
| Gemini Enterprise and Gemini Notebook | skills.google/paths/3666 | 6-activity path; Gemini Notebook for document insight + CX Agent Studio for multi-agent CX (adjacent, not core to SOW use case). |
| Deploy Multi-Agent Systems with Gemini Enterprise Agent Platform | skills.google/course_templates/1275 | This is the **pro-code ADK path** (parent-child agents, tools, local dev → deploy to Agent Runtime). 6h advanced. Page states it "relies on a **pre-released version** of this product" — treat as pre-GA/unstable, opt-in only, likely to touch GCP billing. Confirms this stays out of the default $21 no-code design. |

Net verdict: no factual corrections needed to the prior architecture (grounding via Data
Stores/connectors → Agent Designer main+subagents → Deep Research → Canvas export). This
table is additive confirmation, not a fix.

## Cloud Console IAM roles (verified 2026-08-23)

For building via console.cloud.google.com/gemini-enterprise (Standard/Plus/PAYG/
Frontline, not Business — see fork below), the project-level IAM roles are:

| Role | ID | Covers |
|---|---|---|
| Gemini Enterprise Admin | `roles/discoveryengine.agentspaceAdmin` | Everything: create apps, data stores, connectors, Agent Designer, publish, team access. **Minimum single role for the whole build workflow.** |
| Discovery Engine Editor | `roles/discoveryengine.editor` | Create/manage apps, data stores, agents; no team/admin settings. |
| Gemini Enterprise User | `roles/discoveryengine.agentspaceUser` | Use apps, create agents, basic connector ops — not full admin. |
| Discovery Engine Viewer | `roles/discoveryengine.viewer` | Read-only. |

Note the role IDs still say **"agentspace"** — Gemini Enterprise's pre-rebrand name —
even though the product/console UI says "Gemini Enterprise." Not a typo; the IAM
surface hasn't been renamed to match. Grant syntax:
`gcloud projects add-iam-policy-binding PROJECT --member="user:EMAIL" --role="roles/discoveryengine.agentspaceAdmin"`.

## Cloud Console vs. Business edition — the provisioning fork (verified 2026-08-23)

Two genuinely different products share the Gemini Enterprise name and can both look like
"where you build this":

| | **Business edition** | **Cloud Console "Gemini Enterprise"** |
|---|---|---|
| Where | business.gemini.google | console.cloud.google.com/gemini-enterprise/start |
| Managed by | Workspace Admin (Directory > Users, or Generative AI > Gemini Enterprise) | GCP project IAM + Billing Account |
| Editions covered | Business only | **Standard, Plus, Pay-as-you-go, Frontline — explicitly NOT Business** (quickstart's own words) |
| Price | ~$21/seat flat | Standard ~$30-35/seat, Plus ~$50-60/seat, **PAYG = consumption billing** |
| Prerequisite | Existing Workspace/Cloud Identity org + assigned license | GCP project with billing enabled, Discovery Engine + Cloud Storage + IAM APIs on |

Consequence: a user with only "Cloud Console access" is not automatically on the $21
seat. If they open the Cloud Console Gemini Enterprise page and it offers an edition
picker, that confirms Business isn't active there — proceeding would mean Standard/Plus
(different flat price, still not $21) or Pay-as-you-go (violates "never token-based"
outright). Always check which situation applies before giving build steps; don't default
to Cloud Console steps just because the user has that access.

Source: docs.cloud.google.com/gemini/enterprise/docs/quickstart-gemini-enterprise
("This quickstart applies to Standard, Plus, Pay-as-you-go, and Frontline editions, not
Business edition, which uses a separate Help Center") + docs/create-app + docs/apps-data-stores.

## Data store sources — Cloud Storage is optional, not mandatory

An app needs at least one data store, but a data store's source is a choice, not a
requirement to use GCS specifically. Confirmed options include Google Drive, Cloud
Storage, Calendar, Gmail, Chat, BigQuery, Cloud SQL, Spanner, Firestore, Bigtable,
AlloyDB, plus 100+ third-party connectors (Salesforce, Jira, Confluence, ServiceNow,
Slack, Teams, Zendesk…). **A Cloud Storage bucket is only required if you pick Cloud
Storage as that data store's source.** For a one-off doctrine/context upload, Drive or
direct upload avoids touching GCS or its billing surface at all.

## Code execution sandbox — reportlab PDF generation is real (verified 2026-08-23)

Confirmed: Gemini's code-execution sandbox ships with a pre-installed library set
including **reportlab**, matplotlib, pandas, pdfminer, numpy, sympy, tabulate, etc. —
no arbitrary pip installs, but this fixed set covers real PDF generation. Runs up to
30s per call, up to 5 calls without re-prompting.

**Unresolved caveat, don't assert past this:** the doc that confirms this is under the
**Agent Platform** tree (docs.cloud.google.com/gemini-enterprise-agent-platform/scale/
sandbox/...) — the pro-code side. Not yet confirmed whether this exact sandbox is
exposed inside the plain Business-edition chat / Gem surface to a non-coding end user,
or only to custom-built (Agent Platform) agents. This is a 10-second in-product check
(open a Gem or Agent Designer agent, ask it to run a Python snippet) — do that check
before designing a pipeline that depends on it, rather than asserting either way.

## Gems — real, but NOT inside the Gemini Enterprise app (verified 2026-08-23)

**Gems is a feature of gemini.google.com (the separate consumer Gemini app), not a
section inside the Gemini Enterprise app/console.** A Business-edition license does
unlock Gems access — "Gems will be available in Gemini (gemini.google.com) by default
to all Gemini Enterprise, Business, Education and Education Premium users" — but you
build/use them at gemini.google.com, never at business.gemini.google. There is a live
Google support-community thread titled "No Gems in Gemini Enterprise Business Edition"
from people who looked for it in the wrong place — don't repeat that mistake in a design.

Gems = one saved persona/system-prompt for a continuous chat thread, with file/Drive
attachment (≤10 files). It is NOT the same mechanism as Agent Designer (which is a real
main-agent + subagents flow). A single Gem simulating "Stage 1 / Stage 2 / Stage 3" via
system-prompt instructions is one model reasoning sequentially in one context — not
genuine parallel fan-out and not genuine independent verification by a different agent.
Since Agent Designer costs the same $21 flat seat, prefer it over a self-verifying Gem
whenever the user's requirement is real separation (e.g. "verified by a different
agent") — there's no cost reason to accept the weaker mechanism.

## Grounding-source cost nuance

For uploading `doctrine.txt` / context files, prefer a **Google Drive** folder connector
over creating a **Cloud Storage** data store. Drive is a bundled Business-seat app;
Cloud Storage is a GCP resource and, even at trivial cents-per-GB, is a small crack in
the "purely per-seat" guarantee and may need a linked GCP project. Chat upload (≤50MB) is
the simplest zero-setup option for one-off files.
