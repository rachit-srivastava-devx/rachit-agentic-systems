---
name: lld-diagram-standard
description: Standing rule — any low-level design (LLD) / system architecture diagram the user asks for, in any project, must be built at full component-level detail, never a simplified high-level sketch. Use whenever the user asks to create, update, or regenerate an LLD, system design, or low-level architecture diagram, or says a diagram is "missing details" / "too high-level."
---

# LLD diagrams are always full detail

## The rule

Origin, 2026-09-11, `Light/fleet` repo: a first pass at a "low-level system design" diagram
used ~17 invented, high-level components and was rejected outright — "you did a bad job, half
of the details are not there." A second pass, rebuilt from that project's own detailed spec
(`docs/design/fleet-harness/LLD.md`), landed at 32 real components and was accepted. The
follow-up instruction generalized it: **every LLD diagram, in every project, from now on** —
not a one-off fix for that repo.

"Low-level design" and "high-level design" are different artifacts. If the user asks for an
LLD, a system design diagram, or says an existing one is too shallow, they want the low-level
one: every distinct component, decision gate, queue, data store, and named mechanism as its own
node — not a 5-8 box summary. When genuinely unsure whether "diagram" means high-level or
low-level, the default under this rule is low-level; ask only if the request is ambiguous about
which artifact is wanted at all (e.g., "show me the architecture" with no other qualifier).

## How to find "full detail" in a new project

1. **Reuse before inventing.** Check for an existing design doc, spec, requirements list, or
   ADR in the project first (`grep`/`find` for `LLD`, `design`, `ARCHITECTURE`, `spec` near the
   request's topic). If one exists, pull every named component/mechanism from it directly —
   do not independently re-derive a parallel, thinner structure. This was the exact mistake in
   the origin incident: a fresh diagram was built without checking `LLD.md` first, and came out
   worse than what already existed.
2. **If no existing doc exists**, derive exhaustively from whatever the user just gave you
   (a requirements list, a pasted reference diagram, a verbal description). Rule of thumb from
   the origin case: a "clean high-level" pass under-counts by roughly 2-3x — go through every
   requirement/behavior named and check it has a node, or is explicitly folded into another
   node's sublabel with a name, not silently dropped.
3. **Never silently drop a mechanism for space.** If a real detail can't fit as its own node
   without cluttering the diagram, fold it into an existing node's sublabel (e.g., "two-tier
   secret scan" folded into a `Verify` node's sublabel) — don't just omit it.

## Executing it (archify), lessons paid for once already

- **Build vertically, not horizontally.** A wide diagram (many nodes per row) fails archify's
  1440px desktop-readability check hard, because the whole SVG scales down to fit viewport
  width. Going from a ~3080px-wide layout to a ~1500px-wide, tall layout took projected text
  from ~2px (fail) to ~5.5-6px (pass) at the *same* component count. Height has no equivalent
  hard ceiling; width does. Stack in columns, use a narrow main spine, put side/cross-cutting
  systems in their own vertical lane next to it.
- **Target `meta.quality_profile: "standard"`, not `"showcase"`.** An information-dense LLD
  cannot clear showcase's absolute font-size floor without gutting content. Standard's 9
  structural checks (crossings, corridors, label clearance, orthogonality) are the real
  correctness bar and are fully achievable; showcase adds only a legibility nice-to-have on top.
- **Iterate with the raw renderer first**, not the CLI's `--json` validate mode — the JSON path
  hides the actual diagnostic text behind a fail-closed boundary when the renderer throws:
  ```bash
  cd ~/.claude/skills/archify
  ARCHIFY_QUALITY_PROFILE=standard node ./renderers/architecture/render-architecture.mjs \
    <spec.json> /tmp/preview.html
  ```
  Fix exactly what each diagnostic names: align exact center-x for anything meant to be a pure
  vertical edge (a few px of drift causes the router to mis-infer `fromSide`/`toSide`); add
  `labelDy`/`labelAt` per the tool's own suggested fix when a label overlaps a node; route any
  edge that must travel back up the spine through a dedicated side corridor with explicit
  `fromSide`/`toSide`/`via`, never straight through unrelated nodes. Repeat until exit 0, then
  run the real `validate`/`deliver`/`visual-check` commands for the acceptance record.
- **Persist the spec in the project**, not a temp scratchpad — future edits should modify the
  existing `.architecture.json` incrementally, not regenerate from scratch. Put it next to
  whatever design doc it was built from.

## Worked example

`Light/fleet`'s `.claude/skills/fleet-harness-lld-diagram/SKILL.md` is the project-specific
instance of this rule: it names the exact source doc, the current component list, and the file
paths for that one diagram. Use it as a template for how to scope a project-specific skill
under this same standard, if a project accumulates enough diagram-specific detail to warrant
its own file.
