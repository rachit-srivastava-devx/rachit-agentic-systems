#!/usr/bin/env bash
# l8-code-router.sh — UserPromptSubmit hook: route coding requests to the l8-code skill.
#
# Why a hook and not a line in CLAUDE.md: a memory file is guidance that gets shed under pressure in
# a long session. The enforcement test is — if ignoring the rule once costs annoyance, a doc is fine;
# if it costs an incident, it needs a hook. Shipping a defect is an incident.
#
# For UserPromptSubmit, stdout is added to the model's context, so this prints a directive when the
# prompt looks like a coding request and stays completely silent otherwise. Silence matters: an
# injection that fires on every turn is noise, and noise gets ignored along with everything near it.
#
# Precision over recall, deliberately. A new gate's first run is mostly false positives, so the
# matcher is tuned against a labelled prompt set in --selftest and requires either one unambiguous
# signal or a verb+noun pair.
#
# Fail-safe: any error exits 0 and prints nothing. This hook must never block a prompt.
#   --selftest   score the matcher against labelled prompts (exit 6 on a miss)
#   --explain    read a prompt from stdin and report only the match decision

set -uo pipefail

MODE="hook"
case "${1-}" in
  --selftest) MODE="selftest" ;;
  --explain)  MODE="explain" ;;
  '') ;;
  *) exit 0 ;;
esac

# ---------------------------------------------------------------------------
# is_coding_prompt <text>  -> 0 when the prompt is a coding request
#
# Two ways to match:
#   STRONG  one unambiguous coding signal is enough.
#   COMBO   a code verb AND a code noun, so "write a blog post about X" does not match on "write".
# ---------------------------------------------------------------------------
is_coding_prompt() {
  local t; t="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')"

  # STRONG — these essentially never appear in a non-coding request.
  local strong='refactor|debug|implement|stack ?trace|traceback|compile|compiler|segfault|linter|lint |typecheck|type error|unit test|integration test|regression|merge conflict|pull request|code review|codebase|repo |repository|git |commit|rebase|pytest|jest|eslint|tsc |cargo |npm |pnpm |yarn |docker|kubernetes|sql query|migration|api endpoint|race condition|memory leak|null pointer|off.by.one|\bdiffs?\b|\bbranch(es)?\b'
  if printf '%s' "$t" | grep -qE "$strong"; then return 0; fi

  # A path with a source extension, or a fenced code block with a language tag.
  if printf '%s' "$t" | grep -qE '[a-z0-9_./-]+\.(js|mjs|cjs|jsx|ts|tsx|py|go|rs|rb|java|kt|swift|php|c|h|cpp|hpp|sh|bash|zsh|sql|yaml|yml|toml|json)\b'; then return 0; fi
  if printf '%s' "$1" | grep -qE '```[a-zA-Z]+'; then return 0; fi

  # COMBO — a coding verb plus a coding noun.
  local verbs='write|code|build|creat|implement|fix|patch|add|chang|modif|updat|rewrit|optimi|migrat|renam|delet|remov|extract|wire|hook up|integrat|ship|deploy|test|review|profil|inspect|handl|valid|pars|seriali'
  local nouns='function|method|class|module|script|file|bug|test|endpoint|route|component|feature|library|package|service|handler|parser|schema|model|query|interface|type|struct|enum|hook|middleware|cli|server|client|api|config|dependency|error|exception|variable|loop|array|string|helper|util|utility|wrapper|retry|timeout|cache|queue|worker|job|regex|import|payload|request|response|state|store|hook'
  if printf '%s' "$t" | grep -qE "\\b($verbs)" && printf '%s' "$t" | grep -qE "\\b($nouns)"; then return 0; fi

  return 1
}

DIRECTIVE='<l8-code-routing>
This prompt is a coding request. Invoke the `l8-code` skill (Skill tool, skill: "l8-code") before
writing or changing code, and follow it: bearings -> reuse-check -> contract -> build for the
unenumerated cases -> verify at the layer of the claim.

Do not report the work as done until all three verification steps have actually run:
  1. the project'"'"'s own gate (lint/typecheck/tests) with real pasted output,
  2. `bash ~/.claude/skills/l8-code/scripts/selfcheck.sh` over the changed files,
  3. the real behaviour driven end to end for anything a human sees or calls.
A proxy is not the property: HTTP 200 is not a rendered page, and exit 0 after a pipe is not a pass.
</l8-code-routing>'

# ---------------------------------------------------------------------------
# selftest — labelled prompts. Tuned here so it is not tuned on the user.
# ---------------------------------------------------------------------------
if [ "$MODE" = "selftest" ]; then
  should_match=(
    "fix the login bug in auth.ts"
    "write a function that dedupes a list"
    "refactor this module"
    "why is my test failing"
    "add a retry to the fetch helper"
    "implement pagination for the users endpoint"
    "this throws a null pointer, help"
    "review my diff before I push"
    "migrate the schema to add a column"
    "optimise this query, it is slow"
    "build a CLI that reads a csv"
    "debug why the server 500s"
    "update the config file"
    "rename the parser class everywhere"
    "can you write unit tests for the cache"
  )
  should_not_match=(
    "what is the capital of France"
    "write a blog post about remote work"
    "summarise this article for me"
    "book me a flight to Delhi"
    "explain the history of the Roman empire"
    "draft an email to my landlord"
    "what should I cook tonight"
    "who won the match yesterday"
    "translate this sentence to Hindi"
    "make me a workout plan"
    # Adjacent cases: technical, but questions rather than coding REQUESTS. "the difference"
    # matched the `the diff` pattern here before a word boundary was added.
    "what is the difference between TCP and UDP"
    "explain what a closure is"
    "should I use postgres or mongo for my startup"
    "what is big O notation"
    "what are your thoughts on rust vs go"
    "how much does AWS lambda cost"
  )
  tp=0; fn=0; fp=0; tn=0
  for p in "${should_match[@]}"; do
    if is_coding_prompt "$p"; then tp=$((tp+1)); else fn=$((fn+1)); printf '  MISS      %s\n' "$p"; fi
  done
  for p in "${should_not_match[@]}"; do
    if is_coding_prompt "$p"; then fp=$((fp+1)); printf '  FALSE+    %s\n' "$p"; else tn=$((tn+1)); fi
  done
  printf 'coding prompts matched:     %d/%d\n' "$tp" "$((tp+fn))"
  printf 'non-coding prompts quiet:   %d/%d\n' "$tn" "$((tn+fp))"
  [ "$fn" -eq 0 ] && [ "$fp" -eq 0 ] && { echo "router selftest: PASS"; exit 0; }
  echo "router selftest: FAIL"
  exit 6
fi

# ---------------------------------------------------------------------------
# hook / explain
# ---------------------------------------------------------------------------
INPUT="$(cat 2>/dev/null || true)"

# Prefer the structured `prompt` field; fall back to the raw payload if jq is absent, so the hook
# still works on a machine without it rather than silently doing nothing.
PROMPT=""
if command -v jq >/dev/null 2>&1; then
  PROMPT="$(printf '%s' "$INPUT" | jq -r '.prompt // empty' 2>/dev/null || true)"
fi
[ -z "$PROMPT" ] && PROMPT="$INPUT"
[ -z "$PROMPT" ] && exit 0

if is_coding_prompt "$PROMPT"; then
  [ "$MODE" = "explain" ] && { echo "MATCH"; exit 0; }
  printf '%s\n' "$DIRECTIVE"
else
  [ "$MODE" = "explain" ] && { echo "no-match"; exit 0; }
fi
exit 0
