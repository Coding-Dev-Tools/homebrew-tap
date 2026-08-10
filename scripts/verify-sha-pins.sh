#!/usr/bin/env bash
# Regression guard: every `uses:` directive in .github/workflows/*.yml must be
# SHA-pinned (40 hex chars after @). Mutable tags like @v4 or @main are a
# supply-chain risk — an upstream tag rewrite can silently change what runs.
#
# Usage: scripts/verify-sha-pins.sh [WORKFLOWS_DIR]   (default: .github/workflows)
# Exit 0 if all uses: lines are pinned; exit 1 otherwise.
set -uo pipefail

WORKFLOWS_DIR="${1:-.github/workflows}"
fail=0
okc=0

shopt -s nullglob
for yml in "${WORKFLOWS_DIR}"/*.yml "${WORKFLOWS_DIR}"/*.yaml
do
  # Match lines like:  - uses: owner/action@ref
  while IFS= read -r line
  do
    # Extract the ref portion after @
    ref="$(echo "${line}" | grep -oP 'uses:\s*\S+@\K\S+' || true)"
    if [[ -z "${ref}" ]]
    then
      continue
    fi
    # A valid SHA pin is exactly 40 lowercase hex characters
    if [[ ${ref} =~ ^[0-9a-f]{40}$ ]]
    then
      okc=$((okc + 1))
    else
      echo "::error file=${yml}::unpinned action ref '${ref}' — use a full commit SHA instead of a mutable tag"
      fail=1
    fi
  done < <(grep -nP '^\s*-?\s*uses:' "${yml}" 2>/dev/null || true)
done

echo
if [[ ${fail} -eq 0 ]]
then
  echo "sha-pin-verify: PASS — ${okc} pinned uses: directive(s) found."
else
  echo "sha-pin-verify: FAIL — one or more unpinned uses: directives above."
fi
exit "${fail}"
