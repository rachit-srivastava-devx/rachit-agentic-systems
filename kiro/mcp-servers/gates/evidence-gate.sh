#!/usr/bin/env bash
# evidence-gate.sh — PostTaskExec gate.
# Enforces modernise AGENTS.md R2 + the CATEGORY-TEMPLATE definition-of-done:
# a category folder is NOT done until its four files exist and its VERIFICATION.md
# carries pasted command output (not an empty checklist) and an explicit evidence tier.
#
# This is a heuristic structural check — cheap, mechanical, non-skippable. It does NOT
# re-run codex or go test (those are separate tools); it verifies the ARTIFACTS of the
# pipeline are present and non-hollow, which is the failure mode R2 targets.
#
# Config via env:
#   MODERNISE_CATEGORY_DIR   absolute path to the category folder just worked on.
# If unset, the gate scans nothing and passes (exit 0) — it only gates a named folder.
# Exit 2 BLOCKS completion; stderr is surfaced to the agent.

set -uo pipefail
cat >/dev/null 2>&1 || true

DIR="${MODERNISE_CATEGORY_DIR:-}"
if [[ -z "$DIR" ]]; then
  exit 0
fi
if [[ ! -d "$DIR" ]]; then
  echo "evidence-gate: MODERNISE_CATEGORY_DIR=$DIR does not exist." >&2
  exit 2
fi

fail=0
note() { echo "evidence-gate: $1" >&2; fail=1; }

for f in CONTRACT.md BLUEPRINT.md TDD-SPEC.md VERIFICATION.md; do
  [[ -f "$DIR/$f" ]] || note "missing required file: $f"
done

VF="$DIR/VERIFICATION.md"
if [[ -f "$VF" ]]; then
  # Evidence tier must be stated explicitly.
  if ! grep -Eq 'CONFIRMED|DRIFTED-CONFIRMED|PLAUSIBLE|NOT-FOUND|REFUTED' "$VF"; then
    note "VERIFICATION.md has no explicit evidence tier."
  fi
  # A checked citation box with no pasted output is the defect R2 names. Heuristic:
  # if there are checked boxes but no fenced code / no shell-prompt / no 'result:' text,
  # the checklist is hollow.
  checked=$(grep -Ec '^\s*- \[x\]' "$VF" || true)
  hasoutput=$(grep -Ec '```|\$ |exit code|result:|ok\s|FAIL|PASS' "$VF" || true)
  if [[ "$checked" -gt 0 && "$hasoutput" -eq 0 ]]; then
    note "VERIFICATION.md has $checked checked box(es) but no pasted command output (R2 violation)."
  fi
  # No-stub check must be present.
  grep -q 'No-stub check' "$VF" || note "VERIFICATION.md missing the No-stub check section."
fi

TDD="$DIR/TDD-SPEC.md"
if [[ -f "$TDD" ]]; then
  # A red/green spec with no fenced go code is prose-dressed-as-a-test.
  if ! grep -q '```go' "$TDD"; then
    note "TDD-SPEC.md contains no fenced \`\`\`go block — test may be described, not real (no-stub risk)."
  fi
  # Banned always-true assertion.
  if grep -Eq 'assert\.True\(\s*t\s*,\s*true\s*\)' "$TDD"; then
    note "TDD-SPEC.md contains a banned always-true assertion (assert.True(t, true))."
  fi
fi

if [[ "$fail" -ne 0 ]]; then
  echo "evidence-gate: BLOCKED — category is not done per AGENTS.md R2 / definition-of-done. Fix the items above." >&2
  exit 2
fi

echo "evidence-gate: OK — $DIR passes the structural evidence check."
exit 0
