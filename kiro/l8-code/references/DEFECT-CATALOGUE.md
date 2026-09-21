# DEFECT-CATALOGUE.md — specific bugs that shipped, with their blast radius

Each entry is a real defect. The **cost** column is what it actually did, because a defect with a
remembered cost gets avoided and a defect described in the abstract does not.

Detectors marked **[auto]** are implemented in `scripts/selfcheck.sh`. The rest need eyes.

---

## Shell

| # | Defect | Cost | Detector |
|---|---|---|---|
| S1 | `$?` read after a pipeline | A scan reported "exit 0 / 0 failures" while its own verdict was FAIL. Written down as a lesson, then repeated **six** more times. | **[auto D1]** · use `set -o pipefail` or `${PIPESTATUS[0]}` |
| S2 | `mktemp` template with characters after `XXXXXX` | Valid on GNU; on BSD/macOS it creates a **literal** file named with X's. First test passed, every later one failed "File exists". | **[auto D2]** · `XXXXXX` must be last |
| S3 | `npx --yes` / `bunx` at many call sites | Re-resolves the package per call. Nine sites → **load average 825**, 89 orphaned processes reparented to PID 1. | **[auto D3]** · install once, then invoke |
| S4 | stdin-consuming command inside `while read` | `brew install` ate the loop's stdin. Manifest silently truncated after one row; script exited **clean**. | **[auto D4]** · add `</dev/null` |
| S5 | `rm -rf` on a path not from `mktemp -d` | A temp dir derived from a content digest collided between two concurrent runs; one deleted the other's cwd. **Machine wedged 40 minutes, twice.** | `mktemp -d` for anything later deleted |
| S6 | Editing a script while it is running | Bash reads by byte offset; inserting bytes mid-run corrupts the parse. Bogus syntax error on a valid line. | Never edit a running script — copy, edit, swap |
| S7 | Shell **function** called inside `bash -c` | Functions are not inherited by a subshell; env vars are. `$(fn)` expanded to `""` and silently flipped three checks. | Export a resolved value, not a function |
| S8 | Interpreter resolved by PATH order | An old node (v10) was first on PATH while v26 was installed; v10 reads `import` as a syntax error. Checks passed or failed by shell accident. | Resolve by `--version`, never by PATH position |
| S9 | `]` not first in an awk/grep bracket expression | `[A-Za-z0-9_.\[\]()]` closes at the first `]`, so the rest becomes literal regex. The pattern silently stopped matching — a **dead detector that read as clean**. | Put `]` first: `[][A-Za-z0-9_.]` |
| S10 | PCRE syntax in `grep -E` | A `(?!...)` lookahead made the whole ERE invalid; the check matched nothing and reported clean. | ERE only, or `grep -P` explicitly |
| S11 | Filtering `file:line:text` by whole-line regex | An exclusion meant for content matched the **filename** instead, silently disabling the check for any repo under that path. | Scope exclusions to the content field |
| S12 | Hardcoded developer home path | Breaks on every other machine and in CI; also leaks the author's username. | **[auto D8]** |
| S13 | `read -a` with `-d ''` over a null-delimited list | Reads only the **first** record. The check ran on one file out of 1,440 and reported clean. | Use `xargs -0`, or a loop |

## Correctness and state

| # | Defect | Cost | Detector |
|---|---|---|---|
| G1 | Error caught and discarded | The single most common way a broken path reports success. | **[auto D5/D5b]** · re-raise, log, or narrow |
| G2 | Assertion comparing an expression to itself | `shown = nodes.length; total = nodes.length; assert(shown <= total)` — **could never fail**. Replacing it immediately found 3 duplicate ids and 9 orphan records. | **[auto D6, advisory]** |
| G3 | A gate that passes on an empty input set | Reported `lessons[0]` and **PASSED**. Every CI run since was meaningless for that gate. | Assert input count > 0, or fail |
| G4 | A check cheaper to fake than to satisfy | An invariant demanding `generator != verifier` with no exemption for "no model involved" → seven adapters invented fake pairs. **447 of 521 records** passed the central invariant with strings that were not models. | Fix the incentive, not the instance |
| G5 | Test writing outside a temp dir | A suite with no path override wrote **776 of 1011 rows** into the production append-only ledger. Hash chain broken permanently, unrepairable. | **[auto D7]** |
| G6 | Money or precision on a float | Cents vanish invisibly until it is an accounting problem. | **[auto D9]** · integer minor units or Decimal |
| G7 | Wall clock / RNG inside logic | A test that cannot fail today and cannot pass in December. | **[auto D10]** · inject them |
| G8 | Type checking suppressed (`as any`, `@ts-ignore`, `# type: ignore`) | Converts a compile-time failure into a runtime one, at the worst moment. | **[auto D11]** |
| G9 | Concurrent writers during measurement | Two runs of the same suite produced two **different** failure sets; a file flipped state within one minute. A 7-failure result was a race with a live agent, not a defect. | Snapshot when nothing is writing |
| G10 | Variable referenced out of scope | Server down with a `ReferenceError` after an edit that looked fine. | Load/import the module after editing, before claiming done |
| G11 | Two implementations of one concept | `compress`+`compress2`, two `metrics`, two contradictory config tables. New capability lands *inside* the architecture, never beside it. | Basenames differing only by a digit or suffix |
| G12 | "Deleted" but still on disk | A directory was reported removed while still present. | `ls` it |

## Frontend and anything rendered

| # | Defect | Cost | Detector |
|---|---|---|---|
| F1 | Counting DOM nodes as "renders" | 117 nodes present, **0 painted** — a missing stylesheet import let an inline `overflow:hidden` on a 0px root clip everything. | `document.elementFromPoint` hit-test |
| F2 | Trusting `getBoundingClientRect` for visibility | Reports geometry for clipped nodes. | Hit-test + computed visibility |
| F3 | Measuring before the state change settles | A `fitView`-style boolean prop fits once, on mount. Three real fixes were each reported as "did nothing" from a stale first paint. | Re-measure after the change |
| F4 | Contrast measured against the wrong background | Checked against `#fff` while colours rendered on tinted surfaces. 6 pairs failed in the real UI. | Measure against the **computed** background |
| F5 | A CSS selector matching zero elements | `.node-card.kind-insight` matched **0** — the component emits `flow-${kind}`. All 54 nodes rendered unstyled. | Assert every new selector matches ≥1 element |
| F6 | A package script pointing at a missing file | `npm run a11y` → `scripts/a11y.mjs`, which did not exist. The design contract was unexecutable for the life of the repo. | **[auto D12]** |
| F7 | An element below the fold reported as present | A primary pane sat 100px below the viewport while its a11y check was green. | Screenshot it and look |

## Process and reporting

| # | Defect | Cost | Detector |
|---|---|---|---|
| P1 | Citing an earlier verification instead of re-running | The earlier run had failed with `ENOENT`; the "verified" artifact was a broken symlink. | Re-run. Always |
| P2 | Reporting an agent's number as your own | "95.45% kill rate" was never reproduced; the bare invocation exits 2 and the real run needs 5 env vars. | A claim with no reproducing command is not a result |
| P3 | Exit code 0 taken as "work done" | An agent ran for real — 367s, 9/9 tests passing — and its worktree returned to the pool **clean**. Two branches carried **zero commits**. | Assert a commit sha and `git show --stat` |
| P4 | A percentage with no denominator | "0 violations" was checkable on 74 of 521 records. | Publish the denominator |
| P5 | Absence of evidence from one probe | "0 slash commands, the honest answer" — one hardcoded path on a machine with **88**. | Enumerate every source before reporting zero |
| P6 | An A/B whose arms were not distinct | Dedup collapsed both variants into one record; the "improvement" was an artifact. | Assert the arms differ before comparing |
| P7 | A new gate trusted on its first run | First run scored 55%: four detectors matched their own source, one flagged an entrypoint, one flagged correct code. | Tune on known-good input first |
| P8 | Backups copying secrets | A rotated credential came back through a routine `cp` of a dotfile taken before editing it. | Never snapshot files containing secrets |
| P9 | Bulk rewrite hitting an unintended file | A path regex mangled `node_modules/` in `.gitignore`, so it was **not ignored at all**. | Diff every config file the pattern could reach |

---

## How to use this file

Do not read it end to end before every task. Read the section that matches what is being touched:
shell, state/correctness, rendered output, or reporting. Then run
`scripts/selfcheck.sh` for the mechanised half.

When a new defect is found in real work, add a row — with its actual cost — and, if it can be
mechanised, a detector in `selfcheck.sh` with a positive control. A lesson without a check behind it
has a measured transfer rate of roughly zero.
