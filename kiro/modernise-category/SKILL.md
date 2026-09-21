---
name: modernise-category
version: 1.0.0
description: L8-grade discipline for authoring and verifying one modernization-category blueprint (a CONTRACT.md / BLUEPRINT.md / TDD-SPEC.md / VERIFICATION.md quad) against a real code checkout, sized for autonomous or small-model execution. Use whenever drafting, reviewing, or verifying a category folder under a modernise/ tree (e.g. reachadapter/NN-*, tetris/NN-*), or any similar spec-factory task that must trace every claim to real source, prove tests are not stubs, and carry an explicit evidence tier. Pairs with the l8-code skill and the codex-review / go-test MCP tools.
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
  - Edit
  - Write
triggers:
  - draft a modernise category
  - author a category blueprint
  - verify a category folder
  - modernise category
  - run the category pipeline
---

# modernise-category

One category folder = one independently-executable unit of modernization work, specified so
precisely that a 4B-parameter model (or an unattended agent) can execute it without inferring intent.
This skill is the repeatable procedure for producing and verifying that folder. It operationalizes
the law in `modernise/AGENTS.md` (R1–R7), `CATEGORY-TEMPLATE.md`, and `VERIFICATION.md` so the rules
transfer as a *check that fails*, not prose that is read once and forgotten.

> The premise, borrowed from `l8-code`: a written lesson transfers at a rate near zero. So every rule
> below is stated as a step with a command whose output is the proof — not a claim to be trusted.

---

## Preflight — before writing a single line (enforces R1)

1. **Confirm HEAD.** Read the pinned SHA from the modernise tree's `README.md`/`AGENTS.md`, then:
   `git -C <source-checkout> rev-parse HEAD`. If it does not match the pin, STOP — every citation
   in the tree needs re-verification first. Do not draft against a moved HEAD.
2. **Confirm working tree state.** `git -C <source-checkout> status --porcelain`. If a separate
   session is landing real fixes (non-empty output), note exactly which files, per `PLAN.md §7a`'s
   drift discipline — your "current code" blocks must match what is actually on disk right now, not
   what a sibling catalog quoted yesterday.
3. **Read the originating finding.** Open the `chronicle_button/modernise/{app}/02-ISSUE-CATALOG.md
   §X.Y` this category extends. You are re-verifying a finding, not inventing one.
4. **Check sequencing.** Read `PLAN.md §4`. If this category is in a hard chain (e.g.
   `tetris/01→02→03→04`, `reachadapter/02→11→01`), its predecessors must be verified — not merely
   drafted — before this one's `CONTRACT.md` can state a precondition that is actually satisfiable.

## The four files (CATEGORY-TEMPLATE.md shape — all four required)

Author in this order; each depends on the one before it.

### 1. `CONTRACT.md` — the literal instruction (executor may read this alone)
- **Scope allowlist** and **explicit forbidden list** (R4). A small model does not infer scope from
  prose; enumerate every touchable file and state "any file not listed is out of scope."
- **Preconditions** and **done-criteria** as exact commands with exact expected output/exit codes.
- **Exact edit**: verbatim CURRENT lines (fenced, with line numbers) immediately followed by verbatim
  TARGET lines. A literal before/after — never a description of one.
- Ban judgment words ("improve", "clean up"). Use the register "add a nil check before line 26's
  dereference."

### 2. `BLUEPRINT.md` — the L8 narrative (human / CTO-review audience)
Citation (file:line + HEAD SHA + catalog §) · verbatim current state · the gap (mechanism, severity,
who is exposed) · target design with ≥2 named-and-killed alternatives · blast radius if wrong ·
revisit trigger · sequencing · 3–5 interview questions it answers. Run it through the
`cto-strategic-thinking` lens: right-sized fix, honest blast radius, real org dependencies.

### 3. `TDD-SPEC.md` — the red-then-green sequence (real code, not description)
Exact test path · exact test function name(s) · **full compilable Go test** (not a sketch) · run-red
command with the exact expected failure message *for the stated reason* (and what a compile-error
failure would look like, so the executor can tell them apart) · exact fix hunk · run-green command ·
standing gate · one-line rollback.

### 4. `VERIFICATION.md` — the audit trail (proof, not summary)
Citation checklist with **pasted command output** per claim · evidence tier · no-stub check ·
codex review verdict · Claude review verdict · red/green execution log once actually run.

## Verification — the three checks, run for real (VERIFICATION.md §1–3)

Skipping any one is where the failures live. A green box with no pasted output is itself a defect (R2).

**Check 1 — Citation integrity.** For every file:line and every "current state" block, open the real
file and diff character-for-character:
```
sed -n '<start>,<end>p' <source-checkout>/<file>
```
Mismatch → tag `DRIFTED` (line numbers moved, re-cite) or `REFUTED` (content absent, claim wrong).
Never silently correct without the tag (R7). The reviewer doing this must NOT be the author.

**Check 2 — No-stub check.** The test must call the real function (not a reimplementation), and at
least one assertion must depend on real output (an `assert.True(t, true)`-class constant is banned).
The fix must be real Go, not a comment or TODO.

**Check 3 — Compile-proof, then red/green.** Prefer the test-binary compile-proof over plain
`go build` — it proves the test file itself links against the real dependency graph:
```
go test -c -o /dev/null ./path/to/pkg/...      # via the go-test MCP: go_compile_proof
```
Then the actual cycle in an **isolated worktree, never the shared checkout**:
```
git -C <source-checkout> worktree add ../verify-<category> <head-sha>
# paste TDD-SPEC.md's test verbatim → run red (via go-test MCP: go_test) → expect the PREDICTED
# failure, not a compile error (a compile error means a hallucinated signature → Check 1 failed)
# apply CONTRACT.md's exact target edit → run green → expect pass + standing gate still green
git -C <worktree> diff > modernise/_control/verification-logs/<app>-<category>.patch  # save BEFORE deleting
git -C <source-checkout> worktree remove <worktree>
```
Save the patch as a durable artifact before removing the worktree — a deleted worktree leaves only
prose. Note: on Go 1.27+ real execution works; if you hit a `dyld: missing LC_UUID` load error you
are on a broken toolchain (old Go 1.21 defect) — then compile-proof is the honest ceiling and the
tier caps at PLAUSIBLE.

## Mandatory cross-review (R6)

Whichever party drafted, the *other* reviews — never self-check. Use the codex-review MCP:
```
codex_review(directory="modernise/<app>/<category>", source_root="<source-checkout>")
```
It re-derives every citation against real source read-only and returns CONFIRMED/DRIFTED/REFUTED +
no-stub PASS/FAIL. Read a `read-only` sandbox limitation (e.g. "cannot create temp build dir") as the
*reviewer's* limitation, not a false claim (VERIFICATION.md §5.2) — resolve a genuine disagreement
with a third independent read of the file, not by averaging two guesses.

## Evidence tier — assign explicitly, never leave implicit

| Tier | Meaning |
|---|---|
| CONFIRMED | Citation matches HEAD exactly; test actually run red→green (Check 3). |
| DRIFTED-CONFIRMED | Substance right, line numbers moved; re-cited. |
| PLAUSIBLE | Checked by reading + compile-proof, not executed. The honest default during authoring. |
| NOT-FOUND | Claimed code not locatable; revise CONTRACT.md, do not ship. |
| REFUTED | Investigated, does not match reality; kept in-folder with the tag, not deleted. |

## Definition of done (AGENTS.md §3)

- [ ] All four files present, matching `CATEGORY-TEMPLATE.md` sections.
- [ ] Every citation has a matching pasted-output line in `VERIFICATION.md`.
- [ ] `TDD-SPEC.md` test is real, compilable Go (compile-proof passed) — no stub, no always-true assert.
- [ ] Reviewed by codex AND a second reviewer; any disagreement resolved and recorded.
- [ ] Evidence tier assigned.
- [ ] A "no fix needed, verified" outcome is a legitimate, complete result (R7) — record it, do not drop it.

## Reporting (from l8-code)

Close with: what now holds (and the command to see it) · evidence (real commands, exit codes, output
tails) · what is NOT covered (deliberate gaps, the tier and why it isn't higher) · assumptions. Never
report a category "done" when only Check 1 ran — say plainly which checks executed and which are
specified-but-pending.
