# VERIFICATION.md — how to prove a claim instead of asserting it

The single most expensive failure in software is not a bug. It is a **true measurement of the wrong
quantity**, reported as if it were the thing that mattered. Every row below is a real instance.

```
what was measured              what was claimed              what was actually true
──────────────────────────────────────────────────────────────────────────────────────────────
HTTP 200 from /api/state   ->  "the console works"        ->  page rendered blank for hours
117 nodes present in DOM   ->  "the map renders"          ->  0 painted; overflow:hidden clipped
getBoundingClientRect()    ->  "the node is visible"      ->  rects lie about clipped elements
gate exited 0              ->  "the check passed"         ->  $? was read after a pipe
generator != verifier      ->  "the invariant holds"      ->  neither string was a model
zoom reads 0.32            ->  "my fix did nothing"       ->  measured a stale first paint
recall went 4 -> 7         ->  "my change worked"         ->  dedup collapsed both A/B arms
1,300 tests passing        ->  "the feature works"        ->  flagship view rendered nothing
agent exited 0 in 367s     ->  "the work is done"         ->  branch had zero commits
```

**The generalisation: a proxy is not the property.** Every one of these was caught the same way —
by moving one layer closer to the actual claim.

---

## The method

Before reporting anything as working, run this three-step:

1. **Name the property.** Not "it works" — the specific observable. "The login button is visible and
   clickable at 375px width." "Every row in the export has a non-null `total_cents`."
2. **Ask what would be true if the claim were false.** If the check produces the *same result* in
   both worlds, it is not a check. A test that passes on an empty input set is the canonical case.
3. **Move one layer closer.** Pick the check from the ladder below that actually distinguishes the
   two worlds.

## The ladder — pick the lowest row you can reach

| Claim | Weak proxy (do not report this) | The real check |
|---|---|---|
| An endpoint works | it returns 200 | assert the response **body/schema**, and one error path |
| A page renders | HTTP 200; DOM node count | `document.elementFromPoint` **hit-test** at the element's centre; screenshot and **look at it** |
| An element is visible | `getBoundingClientRect()` has size | hit-test + computed `visibility`/`opacity`/clip; rects report geometry for clipped nodes |
| A colour meets contrast | ratio against `#fff` | ratio against the **computed** background actually behind it |
| A CSS selector applies | the rule exists in the stylesheet | assert it matches **≥1 element** at runtime |
| A shell check passed | the script printed "OK" | the **exit code**, read before any pipe (`set -o pipefail`, or `${PIPESTATUS[0]}`) |
| A gate passed | it exited 0 | it exited 0 **and its input set was non-empty** — measuring nothing is a failure |
| A test suite is meaningful | N tests pass | mutate the code and confirm a test **turns red** |
| The feature is done | unit tests green | **drive it end to end** the way a user does, and capture the artifact |
| A migration is safe | it ran locally | it ran, and the **rollback** ran, on a copy of production-shaped data |
| A fix worked | the metric changed | **re-measure after the state change** — a value cached at mount is not a result |
| An A/B told you something | arm B scored higher | assert the two arms were **actually distinct** before comparing |
| An agent/job did the work | it exited 0 | a **commit sha** and `git show --stat`, or the artifact on disk with nonzero size |
| A file was written | the code path ran | `stat` it: exists, non-zero, **not a symlink** to nothing |
| A library API exists | it looks right | read the **installed version's** docs or type stubs; never recall a signature |
| A dependency was adopted | it's in the manifest | **run it once, end to end**, and record the command that worked |
| Performance improved | the benchmark number moved | same machine, quiet system, N≥5 runs, report the **spread**, not the best |
| A percentage | "97% pass" | publish the **denominator** — 97% of what, and what was excluded and why |

## Reporting rules

- **Paste real output.** Command, exit code, and the tail. Not a summary of what it said.
- **Publish the denominator.** "0 violations" is meaningless without how many were checkable.
  A percentage without its denominator is a claim, not a measurement.
- **Say what you did not check.** An honest gap is information; a silent gap is a defect waiting.
- **Never cite an earlier verification.** Re-run it. The one time this was skipped, the earlier run
  had failed with `ENOENT` and the "verified" artifact was a broken symlink.
- **Do not grade your own work.** Where a second pass is possible, get one. Every self-assessment in
  the corpus behind this file was optimistic; every independent check found real regressions.

## The judgment failures no tool catches

`scripts/selfcheck.sh --list` names the mechanised checks. These are the ones that cost the most and
are **not** mechanisable — no linter, type checker, or test finds them. They are listed here so they
are checked deliberately rather than assumed away:

- Choosing to build what an existing library already owns.
- Reporting a proxy as the property (the whole table above).
- Declaring done before driving the feature end to end.
- A gate that went green because its input set was empty.
- A percentage published without a denominator that matters.
- Abandoning a working approach after two fixable errors.
- Grading your own work.
- Fixing the defect in front of you instead of finishing one path end to end.

The last one is the meta-failure: 23 hours, ~37 components, ~1,300 tests, and **zero** completed
end-to-end runs. Component count is not progress. Completed paths are.
