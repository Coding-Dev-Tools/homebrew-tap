#!/usr/bin/env bash
# Verify every Homebrew formula's `url` is reachable and its `sha256` matches the
# real downloaded tarball. This catches the silent-green failure class where the
# tap's Ruby syntax is valid (so `brew test-bot --only-tap-syntax` passes) yet
# `brew install <formula>` fails because the recorded checksum is wrong or the
# release URL 404s.
#
# Usage: scripts/verify-checksums.sh [FORMULA_DIR]   (default: Formula)
# Exit 0 if every formula verifies (KNOWN_BROKEN entries downgrade to warnings);
# exit 1 if any un-excused formula has a malformed hash, dead URL, or mismatch.
set -uo pipefail

FORMULA_DIR="${1:-Formula}"

# Formulae with a known, upstream-unfixable problem (e.g. the release tag is not
# published yet). These are REPORTED as warnings, not failures, so one broken
# upstream doesn't wedge the whole tap's CI — but every entry is tracked tech
# debt: fix the upstream release, then delete the entry to make it a hard gate.
KNOWN_BROKEN=("saas-churn-predictor")

# sha256 of GitHub's 9-byte "Not Found" 404 body. A formula carrying this hash
# had its checksum computed against a dead URL instead of a real tarball.
NOT_FOUND_HASH="0019dfc4b32d63c1392aa264aed2253c1e0c2fb09216f8e2cc269bbfb8bb49b5"

is_known_broken() {
  local n="${1}" k
  if [[ ${#KNOWN_BROKEN[@]} -eq 0 ]]
  then
    return 1
  fi
  for k in "${KNOWN_BROKEN[@]}"
  do
    if [[ ${k} == "${n}" ]]
    then
      return 0
    fi
  done
  return 1
}

fail=0
warn=0
okc=0
tmp="$(mktemp)"
trap 'rm -f "${tmp}"' EXIT

shopt -s nullglob
for rb in "${FORMULA_DIR}"/*.rb
do
  name="$(basename "${rb}" .rb)"
  url="$(grep -oP 'url "\K[^"]+' "${rb}" | head -1)"
  sha="$(grep -oP 'sha256 "\K[^"]+' "${rb}" | head -1)"

  # 1) Deterministic checks (no network) --------------------------------------
  if [[ ! ${sha} =~ ^[0-9a-f]{64}$ ]]
  then
    echo "::error file=${rb}::${name}: malformed sha256 (must be 64 lowercase hex): '${sha}'"
    fail=1
    continue
  fi
  if [[ ${sha} == "${NOT_FOUND_HASH}" ]]
  then
    if is_known_broken "${name}"
    then
      echo "::warning file=${rb}::${name}: sha256 is GitHub's 'Not Found' error-page hash (dead release URL) — known-broken, tracked."
      warn=$((warn + 1))
      continue
    fi
    echo "::error file=${rb}::${name}: sha256 is GitHub's 'Not Found' error-page hash — the release URL 404s. Recompute from a real tarball."
    fail=1
    continue
  fi

  # 2) Network check: download + compare --------------------------------------
  code="$(curl -sSL --retry 2 --max-time 60 -o "${tmp}" -w '%{http_code}' "${url}" 2> /dev/null || echo 000)"
  if [[ ${code} != "200" ]]
  then
    if is_known_broken "${name}"
    then
      echo "::warning file=${rb}::${name}: url returned HTTP ${code} (known-broken, tracked): ${url}"
      warn=$((warn + 1))
      continue
    fi
    echo "::error file=${rb}::${name}: url returned HTTP ${code}: ${url}"
    fail=1
    continue
  fi
  got="$(sha256sum "${tmp}" | cut -d' ' -f1)"
  if [[ ${got} != "${sha}" ]]
  then
    if is_known_broken "${name}"
    then
      echo "::warning file=${rb}::${name}: sha256 mismatch (known-broken, tracked): have=${sha} real=${got}"
      warn=$((warn + 1))
      continue
    fi
    echo "::error file=${rb}::${name}: sha256 mismatch — 'brew install ${name}' will fail. have=${sha} real=${got}"
    fail=1
    continue
  fi
  echo "ok: ${name}"
  okc=$((okc + 1))
done

echo
if [[ ${fail} -eq 0 ]]
then
  echo "checksum-verify: PASS — ${okc} verified, ${warn} known-broken warning(s)."
else
  echo "checksum-verify: FAIL — ${okc} verified, ${warn} warning(s), and one or more errors above."
fi
exit "${fail}"
