#!/usr/bin/env bash
# head-pin-guard.sh — PreTaskExec gate.
# Enforces modernise AGENTS.md R1: never draft/verify against a moved HEAD.
#
# Reads the hook's JSON context on stdin. Looks for a source checkout and its
# pinned SHA. If the checkout's real HEAD has drifted from the pin, exits 2 to
# BLOCK the task (stderr is surfaced to the agent). Otherwise exits 0.
#
# Config via env (set in the hook definition or the agent's environment):
#   MODERNISE_SOURCE   absolute path to the source checkout (e.g. .../oberon/btngo)
#   MODERNISE_PIN      the expected HEAD SHA
# If either is unset, the gate is a no-op pass (exit 0) — it only guards when told what to guard.

set -uo pipefail

# Drain stdin (hook context JSON) so the writer never blocks; we don't require it.
cat >/dev/null 2>&1 || true

SRC="${MODERNISE_SOURCE:-}"
PIN="${MODERNISE_PIN:-}"

if [[ -z "$SRC" || -z "$PIN" ]]; then
  # Nothing to guard — pass silently.
  exit 0
fi

if [[ ! -d "$SRC/.git" && ! -f "$SRC/.git" ]]; then
  echo "head-pin-guard: MODERNISE_SOURCE=$SRC is not a git checkout — cannot verify pin." >&2
  exit 2
fi

ACTUAL="$(git -C "$SRC" rev-parse HEAD 2>/dev/null)"
if [[ -z "$ACTUAL" ]]; then
  echo "head-pin-guard: could not read HEAD of $SRC." >&2
  exit 2
fi

if [[ "$ACTUAL" != "$PIN" ]]; then
  echo "head-pin-guard: BLOCKED. $SRC HEAD is $ACTUAL but the pin is $PIN." >&2
  echo "Every citation in the modernise tree must be re-verified against the new HEAD before proceeding (AGENTS.md R1)." >&2
  exit 2
fi

echo "head-pin-guard: OK — $SRC at pinned $PIN."
exit 0
