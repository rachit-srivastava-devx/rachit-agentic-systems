---
name: l8-code
description: Principal-engineer coding discipline for any code task — writing, modifying, debugging, reviewing, refactoring, or shipping code in any language or repo. Enforces getting bearings before editing, reusing before building, handling the cases the spec did not enumerate, and verifying at the layer of the claim rather than a proxy for it. Bundles a tuned static-defect scanner. This skill should be used whenever the user asks for code to be written, changed, fixed, reviewed, or completed.
---

# L8 Code

A coding standard distilled from 40 catalogued production failures and 19 repeated corrections. Every
rule here is a scar, not a preference.

The premise, and the reason this is a skill rather than a document: **a written lesson transfers at a
rate near zero.** One lesson in the source corpus ("never read `$?` after a pipe") was written down
and then violated six more times. So where a rule can be made into a check that FAILS, run the
check; where it cannot, say so plainly instead of pretending a paragraph is a guardrail.

---

## The loop

Work one slice at a time. Never one-shot a whole feature.

### 1. Bearings — before the first edit

- Read the nearest `AGENTS.md` / `CLAUDE.md` / `README`, the recent `git log`, and any progress file.
- Locate the code by symbol, not by dumping files. Grep and read for text and config; navigate code
  by its structure.
- Restate the task in one or two sentences, including what is explicitly **out of scope**. If two
  readings of the request lead to materially different work, ask once, now — not after building.

### 2. Reuse — before writing a new file

Search for what already owns the capability: the stdlib, a dependency already in the manifest, an
existing module in this repo. State the branch out loud: **install / extract / build-new**.

If adopting something, **run it once, end to end, and record the command that worked.** An adoption
with no successful invocation is a claim. Two tools in the source corpus were adopted and defended
for a full day without either having ever executed.

### 3. Contract — before the implementation

Write the interface and the failing test first; that is the spec. Then:

- **Minimal surface, hard to misuse.** Make illegal states unrepresentable. No speculative
  abstraction, and no missing seam.
- **Integers for money and precision.** Never floats. Store minor units, or a Decimal.
- **Inject the clock, RNG, and I/O.** No wall-clock or random reads inside pure logic.
- **Guard shared mutable state**, or document the thread contract in a comment.

### 4. Build — handle what the spec did not enumerate

For every input, walk this list explicitly: **empty · null · wrong type · huge · negative ·
duplicate · concurrent · unicode · already-exists · partial failure.**

Never return silently-wrong output. Either handle the case, or raise a **typed, documented** error.
A swallowed exception is how a broken path reports success.

Load `references/DEFECT-CATALOGUE.md` when writing shell, touching money or time, doing concurrent
or filesystem work, or reviewing someone else's diff. It is the specific-bug list with real blast
radii.

### 5. Verify — done means proven, not claimed

Run all three. Skipping any one of them is where the corpus failures live.

**(a) The project's own gate.** Find and run it — `make test`, `npm test`, `cargo test`, whatever the
repo uses, plus lint and typecheck. Paste the real command, exit code, and output tail. Red included.

**(b) The defect scan.** Over the changed files:

```bash
bash ~/.claude/skills/l8-code/scripts/selfcheck.sh
```

Defaults to files changed vs `HEAD`. Exits 6 on a FAIL-tier hit. `--list` shows what it checks *and
what it honestly cannot*; `--selftest` proves every detector still fires. Each FAIL is a defect or
needs a one-line comment saying why it is deliberate.

**(c) The actual behaviour.** For anything a human looks at or calls, drive it end to end the way a
user does, and capture the artifact. Unit tests are the floor, never the bar — in the source corpus,
1,300 tests were green while the flagship view rendered nothing.

Before reporting anything as working, load `references/VERIFICATION.md` and use the proxy→property
ladder. The single most expensive failure in the corpus is a *true measurement of the wrong
quantity*: HTTP 200 reported as "the page works", a DOM count reported as "it renders", `exit 0`
after a pipe reported as "the check passed".

---

## Non-negotiables

- **Never confabulate an API.** Ground every library signature in the installed version's docs or
  type stubs. If it cannot be verified, say "I need to check."
- **Publish the denominator.** "0 violations" is meaningless without how many were checkable.
- **A gate that measured nothing failed.** Passing on an empty input set is a defect, not a pass.
- **Never edit a running script.** Bash reads by byte offset; inserting bytes mid-run corrupts the
  parse into a bogus syntax error on a valid line.
- **Tests write only under a temp dir.** One suite with no path override wrote 776 rows into a
  production append-only ledger and broke its hash chain permanently.
- **Never commit secrets or regenerable caches**; never treat accumulated state as scratch.
- **Say what you did not do.** Report scope you left out and why. An honest gap is information.
- **Do not grade your own work.** Where a second pass is possible, get one. Every self-assessment in
  the corpus was optimistic; every independent check found real regressions.

## Reporting format

Close every coding task with:

1. **What now works** — concretely, and the command to see it.
2. **Evidence** — real commands, exit codes, output tails. Not a summary of what they said.
3. **What is not covered** — deliberate omissions, known gaps, assumptions made.
4. **Assumptions, Big-O, and thread-safety** where they are not obvious.

Never report completion for work that is partially done. If something is blocked, finish everything
else in full and name the blocked part explicitly.

## The failures no tool catches

`selfcheck.sh` mechanises what can be mechanised. Of 40 catalogued failures, **22 cannot be caught by
any linter** — they are judgment errors. Counting them as passes would be the same denominator
dishonesty this skill warns about, so they are listed instead:

choosing to build what already exists · reporting a proxy as the property · declaring done before
driving the feature · a gate green on empty input · a percentage with no denominator · abandoning a
working approach after two fixable errors · grading your own work · fixing the defect in front of you
instead of finishing one path end to end.

The last is the meta-failure: 23 hours, ~37 components, ~1,300 tests, and **zero** completed
end-to-end runs. Component count is not progress. Completed paths are.
