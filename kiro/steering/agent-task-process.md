# Agent Task Process

The path every agent follows on every task:

**spec → verify the spec → fan-out execute → verify with a different model → prove the build.**

The spec is written to docs first, as files. Nothing is executed from memory or
from a plan that lives only in the conversation. The model that verifies is never
the model that produced the work. The build must actually be created — a green
verifier is not proof if the thing does not compile/build.

## 1. Spec — write it to docs first

Break the task into independent, executable units. Each unit is a folder of spec
files written to disk (under a `docs/` or equivalent specs directory), not prose
in chat. Model each unit on the four-file quad (see `modernise/CATEGORY-TEMPLATE.md`
for the canonical shape):

- **CONTRACT** — the literal what: an explicit file allowlist and forbidden list,
  preconditions to check, the one exact change, and done-criteria as exact
  commands with expected output. No adjectives that require judgment.
- **BLUEPRINT** — the why: citation to real source (`file:line` + current HEAD),
  current state verbatim, the gap, the target design with ≥2 named-and-killed
  alternatives, blast radius, revisit trigger, sequencing.
- **TDD-SPEC** — the proof-of-behavior: real, compilable test code (not a sketch),
  the red command + expected failure, the exact fix, the green command, and the
  standing gate that must still pass.
- **VERIFICATION** — the audit trail: every citation checked with pasted command
  output (not summarized), an evidence tier, a no-stub check, and the review record.

Keep spec units atomic and independently checkable. Respect hard sequencing
chains — units with a stated dependency are not parallelized.

## 2. Verify the spec (before any execution)

Check the spec against reality before running anything:
- Every `file:line` citation matches the real source at the stated HEAD.
- The test code is real and compilable, not an always-true assertion or a TODO.
- The allowlist, preconditions, and done-criteria are exact commands, not prose.
- An evidence tier is assigned explicitly, never left implicit.

A spec that cannot be verified against real source is not ready to execute.

## 3. Fan-out execute

Run the independent, verified units in parallel — one worker per unit. Each worker
touches only its allowlist, owns its unit end to end, and produces a checkable
result. A worker that finds it must exceed its scope stops and escalates rather
than expanding scope on its own.

## 4. Verify with a different model

A model that did **not** produce the work reviews it — drafter and reviewer are
always distinct passes, and the roles invert depending on who drafted. The reviewer
checks the result against the spec's done-criteria and records the verdict, pasting
real output. Disagreements are resolved and recorded, never silently dropped.
On failure, repair and re-verify; if the same tactic fails twice, change approach.

## 5. Prove the build

Always confirm the build is actually created. The standing build/test gate for the
project must pass at its stated result before a unit is called done:
- Compile/build the real target (not just a dry run) — the binary/artifact exists.
- Run the project's test suite; it passes at its stated count.
- If the gate fails, the change is reverted, not patched forward.

A unit is done only when its VERIFICATION shows the citation checks, the review,
and the green build/test output — pasted, not summarized.
