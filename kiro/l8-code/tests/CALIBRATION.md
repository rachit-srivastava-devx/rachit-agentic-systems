# CALIBRATION.md — what was measured, on how much, and what is still unmeasured

A gate's precision is a claim until someone publishes the denominator. These are the runs that tuned
`scripts/selfcheck.sh` and `~/.claude/hooks/l8-code-router.sh`, reproducible with the commands shown.

## selfcheck.sh — FAIL-tier precision

| Corpus | Files | FAIL detectors fired | Verdict on each |
|---|---|---|---|
| `fleet/registry` + `fleet/hooks` + `fleet/bin` (mature, reviewed shell + Python) | 83 | 1 — D8 | **True positive**: a real hardcoded `/Users/<name>/…` default in a hook |
| CPython 3.9 stdlib + bundled site-packages | 1440 | 1 — D5 | **True positive**: 14 genuine bare `except: pass` sites |
| `fleet/console` (JS/mjs) | 14 | 0 | — |
| **Total** | **1537** | **0 spurious FAIL** | |

Reproduce:

```bash
bash ~/.claude/skills/l8-code/scripts/selfcheck.sh --selftest
```

Controls, current: **12/12 detectors fire** on their own known-bad fixture; **7/7 FAIL detectors
silent** on known-good fixtures; 1 WARN detector fires on known-good code, which is expected and
counted rather than tuned away.

Runtime: 1537 files in ~30s after batching (was 89s when each detector spawned one grep per file).

## The false positives that shaped the patterns

The first run against real code was mostly false positives, as a new gate's first run always is.
Each was removed by narrowing, not by muting; the shape is now a permanent negative-control fixture.

| Detector | False positive | Resolution |
|---|---|---|
| D1 | `\|` inside a quoted jq program (`'.[] \| select(…)'`) read as a pipeline | Strip quoted spans before testing |
| D1 | `case a\|b)` alternation read as a pipeline | Detect case-pattern arms |
| D1 | `\| jq -e` and `\| bash x` — reading `$?` there is **correct** | Fire only when the last stage is an always-succeeds formatter; read flags, since `-e`/`-q` make a predicate |
| D3 | Matched its own grep search strings, a comment, and a quoted label | Require a statement position; drop comments and search lines |
| D5 | `except ValueError: pass` (try-next-candidate idiom) | Split: broad handlers FAIL, typed handlers became D5b WARN |
| D6 | `assert lookup(name).name == name` — an operand class excluding parens slid **inside** the call | Paren-depth-aware split at the top-level operator |
| D6 | Deliberate equality-semantics tests (`assertTrue(row_1 == row_2)`) | Ignore call-bearing right-hand sides; **demoted to WARN** at 0/3 real defects |
| D7 | Exclusion tested the whole `file:line:text`, matching the **filename** | Content-scoped filtering (`not_in_content`) |
| D8 | `travis` CI path, and a traceback inside a docstring | CI usernames + traceback-line exclusion |
| D9 | `total_calls`, `total_tt` — timing totals, not money | Dropped bare `total`; kept unambiguous money tokens |
| D11 | `as any` matched the English "as well **as any** other" in docstrings | Restricted to TS/JS, where it is a cast |

## Real bugs found in this tooling by running it

Listed because they are the argument for running a gate instead of reasoning about it:

1. **The gate printed FAIL and exited 0.** `report` sat on the right of a pipe, so it ran in a
   subshell and every `fails=$((fails+1))` was discarded. Fixed with command substitution.
2. **D5 scanned 1 file out of 1440 and reported clean.** `read -r -d '' -a` over a null-delimited
   list reads only the first record. Its selftest passed because the fixture set was one file — the
   emptiest kind of green. Fixed with `xargs -0`.
3. **D6 was dead.** `[A-Za-z0-9_.\[\]()]` closes at the first `]` in POSIX awk, so the rest became
   literal regex and the pattern never matched.
4. **D7 was dead.** A `(?!…)` PCRE lookahead inside `grep -E` made the whole ERE invalid; it read as
   clean on every input.
5. **D7 would have skipped any repo under `/tmp`.** See the content-scoping row above.

Every one of these was a check that reported success while measuring nothing.

## l8-code-router.sh — prompt matcher

```bash
bash ~/.claude/hooks/l8-code-router.sh --selftest
```

Current: **15/15** coding prompts matched, **16/16** non-coding prompts silent. The negative set
includes adjacent cases — technical *questions* rather than coding requests ("what is the difference
between TCP and UDP", "explain what a closure is"), since those should not fire the directive.

## What is NOT measured — stated rather than implied

- **The labelled prompt set is 31 prompts.** That is a small denominator. Expect misses on phrasings
  it has not seen; add them to the arrays in `--selftest` when found.
- **No non-English prompts** are in the set.
- **Recall is unmeasured.** These runs bound the false-positive rate, not the miss rate. Nothing here
  says how many real defects the detectors walk past — only that what they report is real.
- **Go, Rust, Ruby, Java, PHP, C++ branches have positive controls but no real-corpus run.** Only
  shell, Python, and JS/TS were tuned against large real codebases.
- **The 22 judgment failures** in `references/DEFECT-CATALOGUE.md` and `--list` are excluded from
  every number above. Counting them as passes would be the denominator dishonesty this skill warns
  about.
