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

**Not included, on purpose:** `auth.json`, OAuth tokens, session/conversation history, sqlite databases, logs, caches, cookies, and Codex's local per-project trust list (real folder paths from this machine). Those are per-person credentials and machine state — never shared, never committed. `node_modules`, compiled binaries, and nested `.git` dirs were also stripped (vendored deps, not config — reinstalled by each tool/skill's own setup step).

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

## MCP servers

MCP (Model Context Protocol) servers give each tool extra tools beyond its built-ins — configured in `claude/mcp.json`, `kiro/settings/mcp.json`, and inside `codex/config.toml`'s `[mcp_servers.*]` blocks. What's wired up:

| Server | In | What it gives the agent |
|---|---|---|
| **`github`** | Claude, Kiro | Read/write GitHub via API — issues, PRs, files, search — without shelling out to `gh`. Needs `GITHUB_PERSONAL_ACCESS_TOKEN` (placeholder in this repo, see **Secrets**). |
| **`sequential-thinking`** | Claude, Kiro | Structured multi-step reasoning scratchpad for problems that need explicit, revisable steps before answering. |
| **`codebase-memory-mcp`** | Claude, Kiro, Codex | A persistent knowledge graph of the codebase: `search_graph`, `trace_path` (call chains / data flow), `get_code_snippet`, `query_graph` (Cypher), `get_architecture`. Session hooks push the agent to use this instead of grep/read for structural code questions — run `index_repository` once per project first. Binary lives at `~/.local/bin/codebase-memory-mcp` (not in this repo — install separately). |
| **`codex-review`** | Kiro | Wraps a review call out to Codex as a second opinion on a diff. Script: `kiro/mcp-servers/codex-review-mcp.mjs`. |
| **`go-test`** | Kiro | Go-specific test tooling — `go_compile_proof`, `go_vet` — auto-approved so it can run without a permission prompt each time. Script: `kiro/mcp-servers/go-test-mcp.mjs`. |
| **`computer-use`**, **`cua_repl`**, **`node_repl`** | Codex | Codex-native: screen/computer control, and a persistent Node REPL for iterative scripting inside a session. |

`kiro/mcp-servers/gates/` (`head-pin-guard.sh`, `evidence-gate.sh`) are supporting shell scripts the above MCP servers shell out to — not servers themselves.

## Agents & hooks

**Claude subagents** (`claude/agents/*.md`) — specialized roles the main session can delegate to, each pinned to a model for cost/capability fit:

| Agent | Model | Role |
|---|---|---|
| `lead-architect` | Opus | Plans and reviews only — writes the contract/acceptance suite first, makes architecture decisions, gives merge verdicts. Never writes bulk code. |
| `mid-engineer` | Sonnet | Implements a briefed task in its own worktree until the pre-written acceptance tests pass. |
| `junior-engineer` | Haiku | Cheapest model — boilerplate, scaffolding, config files, mechanical renames, docs. |
| `researcher` | Haiku | Read-only fan-out search; returns a tight summary, never file dumps, never writes code. |
| `verifier` | Sonnet | Independent, adversarial-by-default reproduction of any "done" claim before it's accepted. |

**Kiro agents** (`kiro/agents/*.json`) are the KiroCrew worker fleet — `kirocrew` (main), `kirocrew-conductor`/`kirocrew-pipeline-conductor` (orchestrate other workers), `kirocrew-heartbeat` (read-only polling worker, runs on a schedule, no write tools), `kirocrew-research` (autonomous multi-cycle research loop that logs findings to disk), `kirocrew-knowledge`/`kirocrew-lite` (lighter-weight variants).

**Claude Code hooks** (`claude/hooks/`) — shell scripts the harness runs automatically at fixed points:
- `l8-code-router.sh` — on every prompt, detects coding requests and routes them into the `l8-code` skill.
- `cbm-code-discovery-gate` — before a tool call, nudges toward `codebase-memory-mcp` search over raw grep/read.
- `cbm-session-reminder` — on session start/resume, reminds the agent the code graph exists.
- `resource-safety-gate` — blocks spawning more subagents when system memory is already critical.

**Codex** (`codex/rules/default.rules`) — a prefix-match allowlist of exact commands (specific `pytest`/`npm` invocations) that run without a permission prompt.

**Kiro** (`kiro/steering/agent-task-process.md`) — the standing task-execution process steering doc, always loaded into context.

## Settings, permissions & plugins

Config that shapes how each tool behaves, beyond skills/agents/MCP:

**Claude** (`claude/`)
- `settings.json` — top-level behavior: hook wiring, `enabledPlugins`, `extraKnownMarketplaces`, theme, notification toggles, auto-compact window.
- `plugins-installed.json` / `plugins-marketplaces.json` — which plugin marketplaces are registered (`claude-plugins-official`, `i-have-adhd`) and which plugins are actually installed from them (`i-have-adhd`, which drives the always-on ADHD-formatted output style).
- `mcp.json` — see **MCP servers** above.

**Kiro** (`kiro/settings/`, `kiro/argv.json`)
- `permissions.yaml` — the capability allowlist: `shell`, `fs_read`, `fs_write` all wide open (`*`), `web_search` open, `web_fetch` restricted to GitHub domains, `mcp` restricted to `kirocrew-core/spawn_run`. This is the actual authorization boundary for what a Kiro session can touch unprompted — tighten this per-teammate risk tolerance rather than copying it verbatim.
- `cli.json` — editor/terminal UX prefs (autocomplete behavior, font, telemetry off, dangerous-command auto-execute on — worth a second look before adopting as-is).
- `argv.json` — low-level Electron/VS Code launch flags (crash reporting, hardware acceleration). Rarely needs changing.
- `mcp.lock` (not copied — a runtime lockfile, regenerates itself) and `powers-installed.json` — Kiro's plugin-equivalent ("powers"); currently empty on this machine.

**Codex** (`codex/config.toml`, `codex/keybindings.json`)
- `config.toml` — the single biggest config file: model + reasoning-effort defaults (`gpt-5.6-luna`, `high`), personality, marketplaces (`openai-bundled`, `openai-primary-runtime`), the full list of enabled plugins (`documents`, `spreadsheets`, `presentations`, `browser`, `chrome`, `pdf`, `visualize`, `codex-security`, `figma`, `cloudflare`, etc. — one `[plugins."name@marketplace"]` block per plugin), desktop app preferences (theme, "open in" target editor), and the `[mcp_servers.*]` blocks documented above.
- A per-project trust list (`[projects."/path/to/project"]`) is generated locally as you use Codex and was **stripped from this export** — it's a list of your own machine's folder paths, not shared config; it rebuilds itself as each teammate opens their own projects.
- `keybindings.json` — global shortcut overrides (currently just clears default bindings for dictation/realtime-voice commands).

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
