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
