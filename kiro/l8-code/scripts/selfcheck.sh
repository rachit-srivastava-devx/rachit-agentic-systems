#!/usr/bin/env bash
# selfcheck.sh — portable static detectors for defects that shipped in real code.
#
# Every detector here corresponds to a defect that actually reached production somewhere and cost
# real time. This is not a linter replacement: it catches the specific class of bug that linters
# and tests both miss, because the code is syntactically fine and the test asserts the wrong thing.
#
# Two tiers, deliberately:
#   FAIL  high-confidence. A hit is a defect (or a deliberate exception worth a comment). Exit 6.
#   WARN  advisory. A hit is often correct code. Printed, never fails the run.
#
# A detector that false-positives gets muted by its owner, and a muted detector is worse than no
# detector. So precision beats recall here: every FAIL detector was tuned against known-good code
# until it was silent, and every detector has a positive control in --selftest proving it can fire.
#
# Usage:
#   selfcheck.sh [paths...]        # default: files changed vs git HEAD, else the cwd tree
#   selfcheck.sh --all             # whole tree, ignoring git
#   selfcheck.sh --selftest        # prove every detector fires on a known-bad fixture
#   selfcheck.sh --list            # what is checked, and what is honestly NOT checkable
#
# Exit: 0 clean · 6 at least one FAIL hit · 2 bad usage · 3 environment problem

# selfcheck:ignore-file — this file embeds deliberately-broken fixtures in --selftest, so every
# detector legitimately matches its own test data. It is reviewed by `--selftest` instead.

set -uo pipefail

VERSION="1.0.0"
SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"

fails=0
warns=0
declared_fail=()

# ---------------------------------------------------------------------------
# grep resolution.
#
# The `grep` a script sees is not always the `grep` an interactive shell sees: some harnesses alias
# it to ugrep, which differs in regex semantics and in how it reports no-match. Resolve a real
# POSIX grep by path and use it everywhere, so a detector cannot pass or fail by shell accident.
# ---------------------------------------------------------------------------
resolve_grep() {
  local c
  for c in /usr/bin/grep /bin/grep "$(command -v grep 2>/dev/null || true)"; do
    [ -n "$c" ] && [ -x "$c" ] || continue
    printf '%s' "$c"; return 0
  done
  return 1
}
GREP="$(resolve_grep || true)"
[ -z "$GREP" ] && { echo "selfcheck: no usable grep on PATH" >&2; exit 3; }

# ---------------------------------------------------------------------------
# Reporting
# ---------------------------------------------------------------------------
hit_fail() {  # hit_fail <id> <label> <evidence-lines>
  local id="$1" label="$2" ev="$3"
  fails=$((fails + 1)); declared_fail+=("$id")
  printf 'FAIL  %-5s %s\n' "$id" "$label"
  printf '%s\n' "$ev" | sed 's/^/            /' | head -8
}
hit_warn() {
  local id="$1" label="$2" ev="$3"
  warns=$((warns + 1))
  printf 'warn  %-5s %s\n' "$id" "$label"
  printf '%s\n' "$ev" | sed 's/^/            /' | head -5
}

# check <tier> <id> <label> <detector-fn> — runs the detector over $FILES and reports.
#
# Deliberately NOT `... | report`: a function on the right-hand side of a pipe runs in a SUBSHELL,
# so `fails=$((fails+1))` inside it updates a copy and is discarded. The first real run of this
# script printed four FAIL blocks and exited 0 — the gate reported its own verdict as green. Using
# command substitution keeps the assignment in the parent shell where the counters live.
check() {
  local tier="$1" id="$2" label="$3" fn="$4" ev
  if [ "$fn" = "_nofiles" ]; then ev="$(d_D12_manifest_dead_script 2>/dev/null)"
  else ev="$(printf '%s\n' "$FILES" | "$fn" 2>/dev/null)"; fi
  # Applied here rather than in each detector so a suppression works uniformly and cannot be
  # forgotten when a new detector is added.
  ev="$(printf '%s\n' "$ev" | "$GREP" -v 'selfcheck:ignore' || true)"
  [ -z "$ev" ] && return 0
  case "$tier" in
    fail) hit_fail "$id" "$label" "$ev" ;;
    warn) hit_warn "$id" "$label" "$ev" ;;
  esac
}

# ---------------------------------------------------------------------------
# File selection
#
# Default to what changed: running every detector over a whole monorepo produces a wall of
# pre-existing hits that trains the reader to ignore the output. Reviewing a change means
# reviewing the change.
# ---------------------------------------------------------------------------
MODE="changed"
TARGETS=()
while [ $# -gt 0 ]; do
  case "$1" in
    --all)      MODE="all" ;;
    --selftest) MODE="selftest" ;;
    --list)     MODE="list" ;;
    --version)  echo "selfcheck $VERSION"; exit 0 ;;
    -h|--help)  sed -n '2,22p' "$SELF" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*)         echo "selfcheck: unknown flag '$1'" >&2; exit 2 ;;
    *)          TARGETS+=("$1"); MODE="explicit" ;;
  esac
  shift
done

# Extensions we understand. Anything else is skipped rather than guessed at.
EXT_RE='\.(sh|bash|bats|zsh|py|js|mjs|cjs|jsx|ts|tsx|go|rs|rb|java|kt|swift|php|c|h|cpp|hpp)$'

collect_files() {
  case "$MODE" in
    explicit)
      local t
      for t in "${TARGETS[@]}"; do
        if [ -d "$t" ]; then find "$t" -type f 2>/dev/null
        elif [ -e "$t" ]; then printf '%s\n' "$t"
        fi
      done
      ;;
    changed)
      if git rev-parse --git-dir >/dev/null 2>&1; then
        # Staged + unstaged + untracked, deletions excluded (a deleted file has no defects).
        #
        # `--relative` on the diff calls: `git diff --name-only` reports paths relative to the repo
        # TOP-LEVEL, while `git ls-files --others` reports paths relative to CWD. Inside a repo that
        # is itself nested under a larger git top-level (this tree checked out as a subdirectory of
        # a bigger repo), those two bases diverge — e.g. "fleet/dev.sh" vs "src/foo.rs" — and the
        # existence check below (which is CWD-relative) silently drops every diff hit, undercounting
        # "N file(s) in scope" with no error printed. Normalizing all three to CWD-relative fixes it.
        { git diff --name-only --diff-filter=d --relative HEAD 2>/dev/null
          git diff --name-only --diff-filter=d --relative --cached 2>/dev/null
          git ls-files --others --exclude-standard 2>/dev/null
        } | sort -u
      else
        find . -type f 2>/dev/null
      fi
      ;;
    all) find . -type f 2>/dev/null ;;
  esac \
    | "$GREP" -Ev '(^|/)(node_modules|\.git|dist|build|target|vendor|\.venv|venv|__pycache__|\.next|coverage)/' \
    | "$GREP" -E "$EXT_RE" \
    | while IFS= read -r f; do
        [ -f "$f" ] || continue
        # A file that CARRIES deliberately-broken fixtures will always match the detectors looking
        # for those defects — this script is the first example. Opt out with `selfcheck:ignore-file`
        # in the first 40 lines. Single lines opt out with `selfcheck:ignore` on the line itself.
        head -40 "$f" 2>/dev/null | "$GREP" -q 'selfcheck:ignore-file' && continue
        printf '%s\n' "$f"
      done
}

# ---------------------------------------------------------------------------
# Batching helpers.
#
# The first version spawned one grep per file per detector: 1440 files x 8 grep detectors took over
# two minutes, and a gate too slow to run does not get run. These hand the whole file list to a
# single grep via xargs instead. `/dev/null` is appended so grep always prefixes filenames, even
# when a batch happens to contain exactly one file.
# ---------------------------------------------------------------------------
gmulti() {  # gmulti <ere>   — file list on stdin, emits file:line:text
  tr '\n' '\0' | xargs -0 "$GREP" -nE "$1" /dev/null 2>/dev/null
}
gmulti_i() { # case-insensitive variant
  tr '\n' '\0' | xargs -0 "$GREP" -nEi "$1" /dev/null 2>/dev/null
}
only_ext() { "$GREP" -E "$1"; }   # filter the incoming file list by extension
# Drop hits that sit inside a comment. `as any` matched the English phrase "as any object files" in
# a prose comment on a real corpus, and a comment describing a defect is not the defect.
no_comments() { "$GREP" -vE ':[0-9]+:[[:space:]]*(#|//|\*|/\*)'; }
# Exclude by MATCHED CONTENT, not by the whole `file:line:text` line.
#
# Filtering the full line silently tested the filename too: excluding `/var/folders` to avoid macOS
# temp-path noise also dropped every hit in any file whose PATH contained it, so D7 went dead inside
# a temp fixture — and would have skipped D7 entirely for any repo checked out under /tmp.
not_in_content() {  # not_in_content <ere>
  awk -v re="$1" '{ i = index($0, ":"); rest = substr($0, i + 1); j = index(rest, ":")
                    content = substr(rest, j + 1)
                    if (content !~ re) print }'
}

# ---------------------------------------------------------------------------
# Detectors
#
# Each takes the file list on stdin via $FILES and emits `path:line: evidence` on stdout.
# Naming: d_<id>_<slug>. Comments record the false positive that shaped the pattern, because the
# next person to widen a pattern needs to know what it already rejected and why.
# ---------------------------------------------------------------------------

# --- D1: $? read after a pipeline that cannot fail --------------------------
# Real cost: a scan script printed "exit 0 / 0 failures" while its own verdict was FAIL, because
# `$?` after `a | b` is B's status, not A's. Written down as a lesson, then violated six more times.
#
# Tuning, from a first run that was 4/6 false positives. `$?` after a pipeline is CORRECT whenever
# the last stage is a real predicate (`grep -q`, `jq -e`, `bash x`) — that status is the one wanted.
# It is a defect only when the last stage is a formatter that essentially always exits 0, making the
# status read meaningless. So the rule is narrowed to that case. Two other false-positive sources
# were removed outright:
#   * `|` inside a quoted string — a jq program like '.[] | select(...)' is not a pipeline.
#   * `|` as case-pattern alternation — `small|medium|large)` is not a pipeline.
d_D1_exit_after_pipe() {
  only_ext '\.(sh|bash|bats|zsh)$' | { files="$(cat)"; [ -z "$files" ] && return 0
    printf '%s\n' "$files" | tr '\n' '\0' | xargs -0 awk '
      # Formatters that succeed regardless of upstream failure, so $? after them says nothing.
      BEGIN { split("tee head tail cat sed awk sort uniq tr wc column nl fold rev cut jq", a, " ")
              for (i in a) fmt[a[i]] = 1 }
      function strip(l) { gsub(/"[^"]*"/, "S", l); gsub(/\x27[^\x27]*\x27/, "S", l); sub(/#.*$/, "", l); return l }
      FNR == 1 { prev_pipe = 0; prev_line = ""; pf = 0 }
      # A file with pipefail set makes $? after a pipeline meaningful; skip the whole file.
      FNR == 1 { pf = 0 }
      /set -[a-z]*o pipefail|set -euo pipefail|set -eo pipefail/ { pf = 1 }
      pf { next }
      {
        raw = $0; line = strip(raw); sub(/^[ \t]+/, "", line)
        if (line == "") next
        # `a|b)` is case-pattern alternation, not a pipeline.
        is_case = (line ~ /^[^;&]*\)[[:space:]]*$/ || line ~ /^[^|]*\|[^)]*\)[[:space:]]*[^|]*;;/)
        is_pipe = (line ~ /\|/ && line !~ /\|\|/ && !is_case)
        if (prev_pipe && raw ~ /\$\?/) {
          n = split(prev_line, seg, /\|/); tailseg = seg[n]
          gsub(/^[[:space:]]*/, "", tailseg); split(tailseg, w, /[[:space:]]+/)
          cmd = w[1]; sub(/.*\//, "", cmd)
          # A flag can turn a formatter into a predicate: `jq -e` and `grep -q` DO set a
          # meaningful status, so read the flags, not just the command name.
          is_pred = (tailseg ~ /(^|[[:space:]])-[a-zA-Z]*e/ && cmd == "jq") || \
                    (tailseg ~ /(^|[[:space:]])-[a-zA-Z]*q/ && cmd == "grep")
          if ((cmd in fmt) && !is_pred)
            print FILENAME ":" FNR ": $? after `... | " cmd "` — that status is " cmd "s, not the real one"
        }
        prev_pipe = is_pipe; prev_line = line
      }
    ' 2>/dev/null
  }
}

# --- D2: mktemp template with characters after XXXXXX -----------------------
# Real cost: `mktemp "$TMPDIR/x.XXXXXX.jsonl"` is valid on GNU and silently creates a LITERAL file
# named with X's on BSD/macOS. First test passed; every later test failed "File exists".
d_D2_mktemp_template() {
  only_ext '\.(sh|bash|bats|zsh)$' | gmulti 'mktemp' \
    | "$GREP" 'XXXXXX' | no_comments \
    | "$GREP" -vE 'XXXXXX("|'"'"'|\)|\}|$|[[:space:]])'
}

# --- D3: repeated `npx --yes` / `bunx` call sites ---------------------------
# Real cost: nine `npx --yes odiff-bin@VER` sites re-resolved the package on every call. Load
# average 825, 89 orphaned processes reparented to PID 1.
# Tuning: ONE guarded call site is normal and was a false positive. Fires only above one per file.
d_D3_npx_yes_repeated() {
  local f n
  while IFS= read -r f; do
    # Three false-positive sources removed after a real run: a script that GREPS for this pattern
    # matched its own source; a comment describing the defect matched; and a quoted human-readable
    # label matched. So require the match to sit at a statement position — start of line, or right
    # after a shell separator — rather than anywhere on the line.
    n="$("$GREP" -nE '(^|[;&|(`]|&&|\|\||[[:space:]](then|do|else))[[:space:]]*(npx[[:space:]]+(--yes|-y)|bunx[[:space:]])' "$f" 2>/dev/null \
          | "$GREP" -vE '^[0-9]+:[[:space:]]*#' \
          | "$GREP" -cvE 'grep|rg |ripgrep|ack |-l "|selfcheck' || true)"
    case "$n" in ''|*[!0-9]*) continue ;; esac
    [ "$n" -gt 1 ] && printf '%s: %s re-resolving call sites (hoist to one install)\n' "$f" "$n"
  done
  return 0
}

# --- D4: stdin-consuming command inside a `while read` loop ----------------
# Real cost: `brew install` inside `while IFS= read` ate the loop's stdin. The manifest silently
# truncated after one row and the script exited CLEAN — the worst possible failure shape.
# Tuning: matching the words anywhere produced 3 false positives on data rows that merely contained
# "brew install" as text. Anchored to a statement position instead.
d_D4_stdin_eaten_in_loop() {
  only_ext '\.(sh|bash|bats|zsh)$' | { files="$(cat)"; [ -z "$files" ] && return 0
    printf '%s\n' "$files" | tr '\n' '\0' | xargs -0 awk '
      FNR == 1 { inl = 0 }
      /while[[:space:]].*read/ { inl = 1 }
      inl && /^[[:space:]]*(if[[:space:]]+)?(brew|npm|pnpm|yarn|cargo|pip|pip3|apt|apt-get|ssh|scp|docker|kubectl)[[:space:]]+[a-z]/ \
        && $0 !~ /dev\/null/ && $0 !~ /^[[:space:]]*#/ { print FILENAME ":" FNR ": stdin-reader in read loop -> " substr($0, 1, 70) }
      /^[[:space:]]*done([[:space:]]|$)/ { inl = 0 }
    ' 2>/dev/null
  }
}

# --- D5: swallowed exception -----------------------------------------------
# A caught-and-discarded error is how a broken feature reports success. This is the single most
# common way "all tests pass" coexists with a dead code path.
# Tuning: `catch (e) { /* intentional */ }` with any body content is NOT flagged — only genuinely
# empty bodies and bare `pass`. Re-raise, log, and typed-narrow forms all pass.
d_D5_swallowed_error() {
  local files; files="$(cat)"
  # Python: BROAD handlers only. `except ValueError: pass` is a legitimate try-next-candidate idiom
  # and false-positived on a real corpus; it moved to D5b as an advisory instead.
  local pyfiles; pyfiles="$(printf '%s\n' "$files" | only_ext '\.py$')"
  [ -n "$pyfiles" ] && printf '%s\n' "$pyfiles" | tr '\n' '\0' | xargs -0 awk '
      FNR == 1 { pend = 0 }
      /^[[:space:]]*except[[:space:]]*:/                                            { pend = FNR; next }
      /^[[:space:]]*except[[:space:]]+(Exception|BaseException)([[:space:]]|:|,)/    { pend = FNR; next }
      pend && /^[[:space:]]*pass[[:space:]]*$/ { print FILENAME ":" pend ": broad exception swallowed by bare pass"; pend = 0; next }
      { pend = 0 }
    ' 2>/dev/null
  printf '%s\n' "$files" | only_ext '\.(js|mjs|cjs|jsx|ts|tsx)$' \
    | gmulti 'catch[[:space:]]*(\([^)]*\))?[[:space:]]*\{[[:space:]]*\}|\.catch\([[:space:]]*\([^)]*\)[[:space:]]*=>[[:space:]]*\{[[:space:]]*\}[[:space:]]*\)' \
    | sed 's/$/  <- empty catch/'
  printf '%s\n' "$files" | only_ext '\.go$' \
    | gmulti 'if[[:space:]]+err[[:space:]]*!=[[:space:]]*nil[[:space:]]*\{[[:space:]]*\}|^[[:space:]]*_[[:space:]]*=[[:space:]]*err[[:space:]]*$' \
    | sed 's/$/  <- error discarded/'
  printf '%s\n' "$files" | only_ext '\.rb$' \
    | gmulti 'rescue[[:space:]]*=>[[:space:]]*[a-z_]+[[:space:]]*$|rescue[[:space:]]+nil[[:space:]]*$' \
    | sed 's/$/  <- rescue swallows/'
}

# --- D5b: narrow typed exception swallowed (advisory) -----------------------
# `except ValueError: pass` is a real idiom (try the next candidate) and a real bug shape (ignore
# the failure and continue with bad state). A detector cannot tell which, so it warns rather than
# failing — a FAIL here would be muted within a week and take D5 down with it.
d_D5b_narrow_swallow() {
  only_ext '\.py$' | { files="$(cat)"; [ -z "$files" ] && return 0
    printf '%s\n' "$files" | tr '\n' '\0' | xargs -0 awk '
      FNR == 1 { pend = 0 }
      /^[[:space:]]*except[[:space:]]+[A-Z][A-Za-z0-9_.]*([[:space:]]+as[[:space:]]+[a-z_]+)?[[:space:]]*:[[:space:]]*$/ \
        && $0 !~ /(Exception|BaseException)/ { pend = FNR; next }
      pend && /^[[:space:]]*pass[[:space:]]*$/ { print FILENAME ":" pend ": typed exception swallowed — is the fallthrough deliberate?"; pend = 0; next }
      { pend = 0 }
    ' 2>/dev/null
  }
}

# --- D6: tautological assertion --------------------------------------------
# Real cost: a check computed `shown = nodes.length; total = nodes.length` then asserted
# `shown <= total`. It could never fail. Replacing it immediately found 3 duplicate ids and 9
# orphan records that had been invisible for the life of the check.
# A check whose two operands are the same expression is not a check.
#
# Two shapes, and the second is the one that actually shipped:
#   (a) literal:   assert(x <= x)                     — same token both sides
#   (b) one-hop:   a = nodes.length                   — different NAMES, same source expression.
#                  b = nodes.length                     This is C22 and it hid 3 duplicate ids and
#                  assert(a <= b)                        9 orphan records for the life of the check.
# So resolve each operand one hop back to its assigned right-hand side within the file before
# comparing. One hop only: deeper tracing needs a real parser and would start guessing.
d_D6_tautological_assert() {
  awk '
    FNR == 1 { delete src }
    function norm(s) { gsub(/[[:space:]]/, "", s); sub(/;$/, "", s); return s }
    # Split an expression at its TOP-LEVEL comparison operator, respecting paren/bracket depth.
    #
    # An earlier version regex-matched an operand class that excluded parens, so on
    # `assert lookup(name).name == name` it slid INSIDE the call and read the left operand as
    # `name` — reporting a tautology that was not there. Depth tracking is the only honest way to
    # find the operator that actually joins the two sides.
    function split_top(expr, out,    i, ch, d, op, oplen) {
      d = 0
      for (i = 1; i <= length(expr); i++) {
        ch = substr(expr, i, 1)
        if (ch == "(" || ch == "[") d++
        else if (ch == ")" || ch == "]") d--
        else if (d == 0) {
          op = substr(expr, i, 3)
          if (op == "===") { oplen = 3 }
          else { op = substr(expr, i, 2); oplen = (op == "==" || op == "<=" || op == ">=") ? 2 : 0 }
          if (oplen) {
            out[1] = norm(substr(expr, 1, i - 1))
            out[2] = norm(substr(expr, i + oplen))
            return 1
          }
        }
      }
      return 0
    }
    {
      line = $0
      if (line ~ /^[[:space:]]*(#|\/\/|\*)/) next
      # Build a one-hop map of simple bindings: `const a = EXPR` / `a = EXPR` / `a := EXPR`.
      if (match(line, /^[[:space:]]*(const|let|var|final)?[[:space:]]*[A-Za-z_][A-Za-z0-9_]*[[:space:]]*(:=|=)[^=]/)) {
        nm = line
        sub(/^[[:space:]]*(const|let|var|final)[[:space:]]+/, "", nm); sub(/^[[:space:]]*/, "", nm)
        eq = index(nm, "=")
        if (eq > 1) {
          key = substr(nm, 1, eq - 1); sub(/:$/, "", key); sub(/[[:space:]]+$/, "", key)
          val = norm(substr(nm, eq + 1))
          if (key ~ /^[A-Za-z_][A-Za-z0-9_]*$/ && length(val) > 3 && val !~ /^["\x27\-0-9]/) src[key] = val
        }
      }
      if (line !~ /assert|expect|require|should/) next
      expr = line
      # Peel the assertion wrapper so the comparison, not the call, is what gets split.
      sub(/^[[:space:]]*/, "", expr)
      sub(/^(self\.)?(assert(True|False|_)?|expect|require|should)[[:space:]]*\(?/, "", expr)
      sub(/\)[[:space:]]*[;,]?[[:space:]]*$/, "", expr)
      if (!split_top(expr, side)) next
      a = side[1]; b = side[2]
      if (length(a) < 2 || length(b) < 2) next
      # A right-hand side containing a CALL may legitimately produce two distinct objects, and
      # comparing them is a real equality test (CPython`s sqlite3 Row tests do exactly this).
      # Only a pure property/attribute read is genuinely the same value twice.
      if (a == b) {
        if (a ~ /\(/) next
        print FILENAME ":" FNR ": both operands are `" a "` — cannot fail"; next
      }
      ra = (a in src) ? src[a] : ""
      rb = (b in src) ? src[b] : ""
      if (ra != "" && ra == rb && ra !~ /\(/)
        print FILENAME ":" FNR ": `" a "` and `" b "` are both `" ra "` — cannot fail"
    }
  ' $(cat | tr '\n' ' ') 2>/dev/null
}

# --- D7: test writing outside a temp dir -----------------------------------
# Real cost: a test suite with no path override wrote 776 of 1011 rows into the PRODUCTION
# append-only ledger. The hash chain broke permanently and was unrepairable.
d_D7_test_writes_outside_tmp() {
  "$GREP" -E '(test|spec|Test|\.bats)' \
    | gmulti '(>|>>|open\(|writeFile|writeFileSync|WriteFile|File\.write|\bcp\b|\bmv\b)[^|;&]*(/Users/|/home/|/var/|/etc/|/opt/|\$HOME|~/)' \
    | not_in_content 'TMPDIR|tmp_path|tmpdir|mktemp|TemporaryDirectory|t\.TempDir|/tmp/|/var/folders' \
    | no_comments \
    | sed 's/$/  <- test writes to a real path/'
}

# --- D8: hardcoded developer home path -------------------------------------
# Breaks on every other machine and in every CI run; also leaks the author's username.
d_D8_hardcoded_home() {
  gmulti '/Users/[a-z][a-z0-9._-]+/|/home/[a-z][a-z0-9._-]+/' \
    | "$GREP" -vE '/(Users|home)/(runner|ci|build|vagrant|node|app|user|USERNAME|travis|jenkins|circleci|gitpod|vscode|codespace|ubuntu|ec2-user|linuxbrew|\$)' \
    | no_comments \
    | "$GREP" -vE ':[0-9]+:[[:space:]]*File "|line [0-9]+, in '
}

# --- D9: money or precision on a float -------------------------------------
# Floats lose cents. Amounts, balances, and totals belong in integer minor units (or a Decimal),
# and the loss is invisible until it is an accounting problem.
# Tuning: WARN, not FAIL — `rate`, `ratio`, and scientific quantities legitimately use floats, and
# a codebase that already uses Decimal will trip the identifier match without a defect.
d_D9_money_float() {
  gmulti_i '(parseFloat|Number\.parseFloat|float\(|: *float|\bdouble\b|\bfloat64\b|\bf64\b)[^)]{0,40}(price|amount|balance|cost|salary|fee|payment|invoice|revenue|charge|subtotal|grand_total|totalPrice|totalAmount|totalCost)|((price|amount|balance|cost|salary|fee|payment|invoice|revenue|charge|subtotal|grand_total|totalPrice|totalAmount|totalCost)[A-Za-z_]*)[[:space:]]*[:=][[:space:]]*(parseFloat|float\(|[0-9]+\.[0-9])' \
    | not_in_content 'Decimal|BigDecimal|BigInt|bigint|_cents|_minor|Cents|Minor' \
    | no_comments
}

# --- D10: nondeterminism in logic ------------------------------------------
# Wall clock and RNG read inside logic make a test that cannot fail today and cannot pass in
# December. Inject them. WARN because entrypoints, seeds, and logging legitimately read both.
d_D10_nondeterminism() {
  "$GREP" -vE '(test|spec|_test\.go|\.bats|main|index|cli|bin/)' \
    | gmulti 'Date\.now\(\)|new Date\(\)|Math\.random\(\)|time\.time\(\)|datetime\.now\(\)|random\.random\(\)|rand\.Int|time\.Now\(\)|uuid4\(\)|randomUUID\(\)' \
    | not_in_content 'inject|clock|Clock|now:|now =|seed' \
    | no_comments
}

# --- D11: suppressed type checking -----------------------------------------
# `as any` / `@ts-ignore` / `# type: ignore` convert a compile-time failure into a runtime one.
d_D11_type_suppression() {
  # Split deliberately: `as any` / `@ts-ignore` are CODE and must not match prose, so comment lines
  # are dropped. `# type: ignore` and `# noqa` ARE comments, so they bypass that filter.
  local files; files="$(cat)"
  { # `as any` is a TS cast — restricted to TS/JS, where it matched the English "as well as any"
    # inside Python docstrings on a real corpus.
    printf '%s\n' "$files" | only_ext '\.(ts|tsx|js|jsx|mjs|cjs)$' \
      | gmulti '@ts-ignore|@ts-nocheck|\bas any\b' | no_comments
    printf '%s\n' "$files" | only_ext '\.(java|kt)$' | gmulti '@SuppressWarnings' | no_comments
    printf '%s\n' "$files" | only_ext '\.py$' \
      | gmulti '#[[:space:]]*type:[[:space:]]*ignore|#[[:space:]]*noqa[[:space:]]*$'
  } | "$GREP" -vE 'ts-expect-error'
}

# --- D12: unresolvable script reference in package manifest ----------------
# Real cost: `npm run a11y` pointed at `scripts/a11y.mjs`, a file that did not exist. The design
# contract was unexecutable for the life of the repo and every "gate" citing it was theatre.
d_D12_manifest_dead_script() {
  local mf
  for mf in package.json; do
    [ -f "$mf" ] || continue
    command -v node >/dev/null 2>&1 || continue
    node -e '
      const fs = require("fs");
      let s = {};
      try { s = (JSON.parse(fs.readFileSync("package.json","utf8")).scripts) || {}; } catch { process.exit(0); }
      for (const [k, v] of Object.entries(s)) {
        const m = String(v).match(/(?:^|\s)(?:node|bash|sh|python3?|tsx|ts-node)\s+([^\s&|;]+\.(?:mjs|cjs|js|ts|sh|py))/);
        if (m && !fs.existsSync(m[1])) console.log(`package.json: script "${k}" -> ${m[1]} DOES NOT EXIST`);
      }
    ' 2>/dev/null
  done
}

# ---------------------------------------------------------------------------
# Runner
# ---------------------------------------------------------------------------
run_detectors() {
  check fail D1  '$? read after a pipeline whose last stage cannot fail'                 d_D1_exit_after_pipe
  check fail D2  'mktemp template has characters after XXXXXX (BSD makes a literal file)' d_D2_mktemp_template
  check fail D3  'repeated npx --yes / bunx re-resolves the package every call'          d_D3_npx_yes_repeated
  check fail D4  'stdin-consuming command inside a read loop truncates it silently'      d_D4_stdin_eaten_in_loop
  check fail D5  'error caught and discarded (a broken path reports success)'            d_D5_swallowed_error
  check fail D7  'test writes outside a temp dir (can corrupt real state)'               d_D7_test_writes_outside_tmp
  check fail D8  'hardcoded developer home path (breaks on every other machine)'         d_D8_hardcoded_home
  check fail D12 'package.json script points at a file that does not exist'              _nofiles

  check warn D5b 'narrow exception silently swallowed — confirm the fallthrough is meant' d_D5b_narrow_swallow
  check warn D6  'assertion may compare an expression to itself — confirm it can fail'     d_D6_tautological_assert
  check warn D9  'money/precision value on a float — use integer minor units or Decimal'  d_D9_money_float
  check warn D10 'wall clock or RNG read inside logic — inject it instead'                d_D10_nondeterminism
  check warn D11 'type checking suppressed — a compile error deferred to runtime'         d_D11_type_suppression
}

# ---------------------------------------------------------------------------
# --list: what is checked, and the honest exclusions
# ---------------------------------------------------------------------------
if [ "$MODE" = "list" ]; then
  cat <<'LIST'
FAIL detectors (a hit fails the run, exit 6)
  D1   $? read after a pipeline
  D2   mktemp template with characters after XXXXXX
  D3   repeated npx --yes / bunx call sites in one file
  D4   stdin-consuming command inside a `while read` loop
  D5   error caught and discarded (empty catch / bare except+pass / discarded err)
  D6   assertion whose two operands are the same expression
  D7   test writing outside a temp dir
  D8   hardcoded developer home path
  D12  package.json script pointing at a nonexistent file

WARN detectors (printed, never fail the run)
  D9   money/precision value held on a float
  D10  wall clock or RNG read inside logic
  D11  type checking suppressed (as any / @ts-ignore / type: ignore)

SUPPRESSION
  selfcheck:ignore        on a line   — suppress that one hit
  selfcheck:ignore-file   in head -40 — skip the whole file (use for fixture-bearing files)

NOT MECHANICALLY CHECKABLE — these are the expensive ones, and no grep finds them.
They are listed rather than silently omitted, because a score that hides its denominator is
a claim, not a measurement. Check them by hand, every time:
  -  reporting a proxy as the property (API 200 as "the page works")
  -  declaring done before driving the feature end to end
  -  building what an existing library already owns
  -  a gate that passes because its input set was empty
  -  a percentage published without its denominator
  -  grading your own work
  -  abandoning a working approach after two fixable errors
LIST
  exit 0
fi

# ---------------------------------------------------------------------------
# --selftest: positive control.
#
# A detector nobody has seen fire is a hypothesis. This builds a known-bad fixture, asserts every
# detector fires on it, then asserts the detectors are SILENT on a known-good fixture. Both
# directions matter: a detector that fires on everything is as useless as one that never fires.
# ---------------------------------------------------------------------------
if [ "$MODE" = "selftest" ]; then
  TMP="$(mktemp -d "${TMPDIR:-/tmp}/selfcheck.XXXXXX")" || exit 3
  trap 'rm -rf "$TMP"' EXIT
  bad="$TMP/bad"; good="$TMP/good"
  mkdir -p "$bad" "$good"

  # ---- known-bad fixtures, one defect each ----
  cat >"$bad/d1.sh" <<'EOF'
#!/usr/bin/env bash
grep foo file.txt | wc -l
if [ $? -ne 0 ]; then echo bad; fi
EOF
  cat >"$bad/d2.sh" <<'EOF'
#!/usr/bin/env bash
t=$(mktemp "$TMPDIR/x.XXXXXX.jsonl")
EOF
  cat >"$bad/d3.sh" <<'EOF'
#!/usr/bin/env bash
npx --yes tool@1 a
npx --yes tool@1 b
EOF
  cat >"$bad/d4.sh" <<'EOF'
#!/usr/bin/env bash
while IFS= read -r pkg; do
  brew install "$pkg"
done < list.txt
EOF
  cat >"$bad/d5.py" <<'EOF'
def load():
    try:
        risky()
    except:
        pass
EOF
  cat >"$bad/d5b.py" <<'EOF'
def load(path):
    try:
        return parse(path)
    except ValueError:
        pass
EOF
  cat >"$bad/d6.js" <<'EOF'
const shown = nodes.length;
const total = nodes.length;
assert(shown <= total);
EOF
  cat >"$bad/d7_test.py" <<'EOF'
def test_writes():
    open("/Users/someone/ledger.jsonl", "a").write("row")
EOF
  cat >"$bad/d8.py" <<'EOF'
CONFIG = "/Users/someone/project/config.yaml"
EOF
  cat >"$bad/d9.ts" <<'EOF'
const totalPrice: number = parseFloat(raw.price);
EOF
  cat >"$bad/d10.ts" <<'EOF'
export function expiry() { return Date.now() + 3600; }
EOF
  cat >"$bad/d11.ts" <<'EOF'
const payload = raw as any;
EOF

  # ---- known-good fixtures: the shapes that must NOT fire ----
  cat >"$good/g1.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
out=$(grep foo file.txt | wc -l)
rc=$?
t=$(mktemp "${TMPDIR:-/tmp}/x.XXXXXX")
npx --yes tool@1 once
while IFS= read -r pkg; do
  printf '%s\n' "$pkg"
done < list.txt
EOF
  cat >"$good/g2.py" <<'EOF'
import logging
from decimal import Decimal

def load(clock):
    try:
        risky()
    except ValueError as exc:
        logging.warning("recoverable: %s", exc)
        raise

def total(rows) -> Decimal:
    return sum(Decimal(r.amount_cents) for r in rows)

def expiry(clock):
    return clock.now()
EOF
  cat >"$good/g3.js" <<'EOF'
const shown = visible.length;
const total = nodes.length;
assert(shown <= total);
try { risky(); } catch (e) { logger.warn(e); }
EOF
  cat >"$good/g4_test.py" <<'EOF'
def test_writes(tmp_path):
    (tmp_path / "ledger.jsonl").write_text("row")
EOF

  # Regression fixtures: every shape below false-positived on the first real tuning run against a
  # mature codebase. They stay here so widening a pattern later trips this control, not the user.
  cat >"$good/g5_fp.sh" <<'EOF'
#!/usr/bin/env bash
# `|` inside a quoted jq program is not a pipeline.
jq -e --arg r "$role" '.[] | select(.id==$r)' "$REG" >"$tmp" 2>/dev/null
found=$?

# `|` as case-pattern alternation is not a pipeline.
case "$lane" in
  -h|--help) usage; exit 0 ;;
  small|medium|large) run_size "$lane"; exit "$?" ;;
esac

# $? after a pipeline whose last stage is a real predicate IS the status wanted.
printf '%s' "$out" | jq -e --arg id "$id" '.results[]?' >/dev/null 2>&1
hit_ec=$?
printf '%s' "$body" | bash "$HOOK"
echo "hook exit: $?"

# A script that SEARCHES for the npx pattern is not a script that calls it.
grep -rn 'npx --yes' src | head -3
grep -c 'npx -y' Makefile
EOF
  cat >"$good/g6_fp.py" <<'EOF'
import os

def resolve(candidate, roots):
    for other in roots:
        try:
            return other, str(candidate.relative_to(other))
        except ValueError:
            pass
    return None, None
EOF

  echo "== positive control: every detector must fire on its own fixture =="
  pass=0; fail=0
  for id in D1 D2 D3 D4 D5 D5b D6 D7 D8 D9 D10 D11; do
    case "$id" in
      D1)  f="$bad/d1.sh";      out="$(printf '%s\n' "$f" | d_D1_exit_after_pipe)" ;;
      D2)  f="$bad/d2.sh";      out="$(printf '%s\n' "$f" | d_D2_mktemp_template)" ;;
      D3)  f="$bad/d3.sh";      out="$(printf '%s\n' "$f" | d_D3_npx_yes_repeated)" ;;
      D4)  f="$bad/d4.sh";      out="$(printf '%s\n' "$f" | d_D4_stdin_eaten_in_loop)" ;;
      D5)  f="$bad/d5.py";      out="$(printf '%s\n' "$f" | d_D5_swallowed_error)" ;;
      D5b) f="$bad/d5b.py";     out="$(printf '%s\n' "$f" | d_D5b_narrow_swallow)" ;;
      D6)  f="$bad/d6.js";      out="$(printf '%s\n' "$f" | d_D6_tautological_assert)" ;;
      D7)  f="$bad/d7_test.py"; out="$(printf '%s\n' "$f" | d_D7_test_writes_outside_tmp)" ;;
      D8)  f="$bad/d8.py";      out="$(printf '%s\n' "$f" | d_D8_hardcoded_home)" ;;
      D9)  f="$bad/d9.ts";      out="$(printf '%s\n' "$f" | d_D9_money_float)" ;;
      D10) f="$bad/d10.ts";     out="$(printf '%s\n' "$f" | d_D10_nondeterminism)" ;;
      D11) f="$bad/d11.ts";     out="$(printf '%s\n' "$f" | d_D11_type_suppression)" ;;
    esac
    if [ -n "$out" ]; then pass=$((pass+1)); printf '  FIRED    %-4s %s\n' "$id" "$(basename "$f")"
    else fail=$((fail+1)); printf '  SILENT   %-4s %s   <- detector is dead\n' "$id" "$(basename "$f")"; fi
  done

  echo
  echo "== negative control: known-good code must not FAIL =="
  # Only FAIL detectors are held to silence. WARN detectors are advisory by construction — D5b
  # fires on `except ValueError: pass`, which is genuinely ambiguous, and demanding zero warnings
  # on real code would force every warning pattern down to uselessness. Advisory hits are counted
  # and shown, never failed, so the number stays honest instead of being tuned away.
  gfiles="$(find "$good" -type f | sort)"
  quiet=0; noisy=0; advisory=0
  for d in d_D1_exit_after_pipe d_D2_mktemp_template d_D3_npx_yes_repeated \
           d_D4_stdin_eaten_in_loop d_D5_swallowed_error \
           d_D7_test_writes_outside_tmp d_D8_hardcoded_home; do
    out="$(printf '%s\n' "$gfiles" | "$d" 2>/dev/null)"
    if [ -z "$out" ]; then quiet=$((quiet+1))
    else noisy=$((noisy+1)); printf '  FALSE+   %s\n' "$d"; printf '%s\n' "$out" | sed 's/^/             /' | head -3; fi
  done
  for d in d_D5b_narrow_swallow d_D6_tautological_assert d_D9_money_float d_D10_nondeterminism d_D11_type_suppression; do
    out="$(printf '%s\n' "$gfiles" | "$d" 2>/dev/null)"
    [ -n "$out" ] && advisory=$((advisory+1))
  done

  echo
  printf 'positive control: %d fired, %d dead\n' "$pass" "$fail"
  printf 'negative control: %d/%d FAIL detectors clean, %d false-positive\n' "$quiet" "$((quiet+noisy))" "$noisy"
  printf 'advisory: %d WARN detector(s) fired on known-good code (expected; not a failure)\n' "$advisory"
  [ "$fail" -eq 0 ] && [ "$noisy" -eq 0 ] && { echo "selftest: PASS"; exit 0; }
  echo "selftest: FAIL"
  exit 6
fi

# ---------------------------------------------------------------------------
# Normal run
# ---------------------------------------------------------------------------
FILES="$(collect_files)"
count="$(printf '%s\n' "$FILES" | "$GREP" -c . || true)"
case "$count" in ''|*[!0-9]*) count=0 ;; esac

# Measuring nothing is a failure, not a pass. A gate that goes green on an empty input set makes
# every run that cites it meaningless.
if [ "$count" -eq 0 ]; then
  echo "selfcheck: no source files in scope — nothing was checked, so nothing passed."
  echo "           pass paths explicitly, or use --all."
  exit 2
fi

echo "selfcheck $VERSION — $count file(s) in scope [$MODE]"
run_detectors "$FILES"

echo
printf 'checked %d file(s): %d FAIL, %d warn\n' "$count" "$fails" "$warns"
if [ "$fails" -gt 0 ]; then
  printf 'failing detectors: %s\n' "${declared_fail[*]}"
  echo 'Each is a defect or needs a one-line comment saying why it is deliberate.'
  exit 6
fi
[ "$warns" -gt 0 ] && echo 'warnings are advisory — confirm each is intentional.'
exit 0
