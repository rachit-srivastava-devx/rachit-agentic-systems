# rachit-agentic-systems

Full agentic setup for Claude Code, Kiro, and Codex CLI — skills, agents, MCP server configs, hooks, and settings. Clone this into a fresh machine and each tool works like the original setup.

## Layout

Each folder mirrors that tool's config home directory:

- `claude/` → merge into `~/.claude/`
- `kiro/` → merge into `~/.kiro/`
- `codex/` → merge into `~/.codex/`

Inside each:
- top-level skill folders — drop-in skills (`SKILL.md` + assets)
- `agents/` — subagent / worker definitions
- `mcp.json` / `config.toml` / `settings.json` — MCP servers, permissions, hooks wiring
- `hooks/`, `steering/`, `rules/` — tool-specific automation and guardrails

**Not included, on purpose:** `auth.json`, OAuth tokens, session/conversation history, sqlite databases, logs, caches, cookies. Those are per-person credentials and machine state — never shared, never committed. `node_modules`, compiled binaries, and nested `.git` dirs were also stripped (vendored deps, not config — reinstalled by each tool/skill's own setup step).

## Notable skills

The skill count is large (600+ per tool, mostly duplicated across `claude/`/`kiro/`/`codex/`), but most of the day-to-day value comes from a small set. A few worth knowing:

| Skill | Where | What it actually does |
|---|---|---|
| **`l8-code`** | `claude/l8-code`, `kiro/l8-code` | Principal-engineer coding discipline for any code task. Forces a fixed loop — get bearings from `AGENTS.md`/`CLAUDE.md`/git log before editing, search for existing code to reuse before writing new code, handle the cases the spec left unstated, and verify at the layer of the actual claim (a passing test, not just an exit code; a rendered page, not just an HTTP 200). Ships a tuned static-defect scanner (`scripts/selfcheck.sh`) run over every changed file before work is called done. Distilled from 40 catalogued production failures — every rule exists because it was violated at least once. |
| **`cto-strategic-thinking`** | `claude/synced/.../cto-strategic-thinking` | Forces CTO/technical-strategist judgment before architecture. Treats an incoming request as a hypothesis ("they believe X produces outcome Y"), not a spec to fill in — checks whether the ask is even the right move before designing a solution. Ends every analysis with one concrete, named, falsifiable recommendation (never just a reframe with no decision attached). Use for build-vs-buy calls, scoping a client engagement, or deciding whether to push back on a requirement. |
| **`devx-doctrine`** | `claude/devx-doctrine`, `kiro/devx-doctrine` | House style for anything written for another person to read — reports, memos, PRDs, decks, one-pagers, dashboards. Combines a restrained editorial visual style (McKinsey/Stripe-influenced typography, color, spacing) with a low-cognitive-load writing style: lead with the conclusion, cite exact numbers instead of vague qualifiers, short declarative sentences. Applied automatically to every doc/artifact except architecture diagrams. |
| **`lld-diagram-standard`** | `claude/lld-diagram-standard`, `kiro/lld-diagram-standard` | Standing rule for low-level design / system-architecture diagrams: always full component-level detail, never a simplified high-level sketch, even if the request just says "make a diagram." Overrides `devx-doctrine`'s visual restraint for this one artifact type. |
| **`code-review`** | built into Claude Code (`/code-review`) | Reviews the current diff, a PR, a branch, or a path for correctness bugs plus reuse/simplification/efficiency issues, at a chosen effort level (low/medium = fewer, high-confidence findings; high/max = broader, may include uncertain ones). Can post findings as inline PR comments (`--comment`) or apply the fixes directly (`--fix`). |
| **`no-mistakes`** | `claude/no-mistakes`, `kiro/no-mistakes` | Pre-push validation pipeline: automated code review, tests, lint, docs, then push/PR/CI — gated so nothing ships without all of them passing. |
| **`security-audit`** (`performance-profiler:security-audit`) | plugin skill | Runs TruffleHog (secrets), Trivy (CVEs), and Semgrep (code patterns) against a project and writes a plain-English report to `security-audit/README.md`. |
| **`devx-project-kb`** | `anthropic-skills:devx-project-kb` | Builds and maintains a 12-section internal Notion knowledge base per client engagement — discovery notes, pain points, architecture decisions, open questions — kept as the single source of truth from first call through delivery. |
| **`adhd-conversation-design`** | `claude/adhd-conversation-design`, `kiro/adhd-conversation-design` | Design/prompting guidance for any assistant or agent talking to a user with ADHD: carry executive load instead of handing it back, lead with the next action, keep multi-step work numbered and short, make progress visible. (This is also why this session's own output is shaped the way it is — ADHD mode is on.) |
| **`gstack`** | `claude/gstack`, `kiro/gstack`, `codex/gstack` | The largest single skill by far (headless-browser QA, ship/land/deploy pipelines, design review, retros, canary monitoring, ~60 sub-skills). A full internal dev-workflow toolkit, not a single-purpose skill — worth its own onboarding pass rather than a one-line summary. |

Everything else is narrower single-purpose skills (PDF/DOCX/XLSX generation, domain-name brainstorming, changelog generation, etc.) — browse the folders directly or grep `description:` in the `SKILL.md` frontmatter to find one:

```bash
grep -h "^description:" claude/*/SKILL.md | sort
```

## Bootstrap on a new machine

### Claude Code
```bash
mkdir -p ~/.claude
cp -r claude/* ~/.claude/
```
Then open `~/.claude/mcp.json` and `~/.claude/settings.json` and fill in any placeholder values (see **Secrets** below).

### Kiro
```bash
mkdir -p ~/.kiro
cp -r kiro/* ~/.kiro/
```
Fill in placeholders in `~/.kiro/settings/mcp.json` and `~/.kiro/agents/kirocrew.json`.

### Codex CLI
```bash
mkdir -p ~/.codex
cp -r codex/* ~/.codex/
```
Then run `codex login` (or your usual auth flow) — `auth.json` is never in this repo, so each person authenticates as themselves.

## Secrets

Every config in this repo has real credentials replaced with a placeholder (`<SET_YOUR_OWN_...>`). Search for `<SET_YOUR_OWN` after copying and fill in your own:

```bash
grep -rn "<SET_YOUR_OWN" ~/.claude ~/.kiro ~/.codex 2>/dev/null
```

Currently that's a `GITHUB_PERSONAL_ACCESS_TOKEN` for the `github` MCP server in `claude/mcp.json`, `kiro/settings/mcp.json`, and `kiro/agents/kirocrew.json` — generate your own PAT at https://github.com/settings/tokens.

**If you find any other real secret in this repo, do not commit a fix — tell @rachit.srivastava to rotate it and redact directly.**

## Updating

This is a periodic export, not a live sync. Re-run the export and re-copy to pick up changes; open a PR for fixes to shared config.
