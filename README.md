# rachit-claude-skills

Personal skill library, shared for the team. Skills for AI coding agents (Claude Code, Kiro, Codex CLI) — each is a `SKILL.md` (plus optional scripts/assets) that gets loaded into an agent session to give it a specialized workflow.

## Layout

- `claude/` — skills from `~/.claude/skills` (Claude Code)
- `kiro/` — skills from `~/.kiro/skills` (Kiro)
- `codex/` — skills from `~/.codex/skills` (Codex CLI)

Each subfolder mirrors the source tool's on-disk skill directory. Some skills appear in more than one folder (installed for multiple agents); large vendored dependencies (`node_modules`, compiled binaries, `.git` internals) were stripped on export — reinstall those per the skill's own setup instructions if needed.

## Using a skill

Copy (or symlink) the skill's folder into the matching directory for your tool, e.g.:

```bash
cp -r claude/<skill-name> ~/.claude/skills/<skill-name>
```

Then invoke it per that tool's convention (e.g. `/skill-name` in Claude Code).

## Updating

This is a personal export, not a live sync — pull latest and re-copy to get updates. PRs welcome for fixes/improvements to shared skills.
