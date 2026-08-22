#!/usr/bin/env bash
# Verify every Homebrew formula's `url` is reachable and its `sha256` matches the
# real downloaded tarball. This catches the silent-green failure class where the
# tap's Ruby syntax is valid (so `brew test-bot --only-tap-syntax` passes) yet
# `brew install <formula>` fails because the recorded checksum is wrong or the
# release URL 404s.
#
# Usage: scripts/verify-checksums.sh [FORMULA_DIR]   (default: Formula)
# Exit 0 if every formula verifies (KNOWN_BROKEN entries downgrade to warnings);
# exit 1 if any un-excused formula has a malformed hash, dead URL, mismatch —
# or if a KNOWN_BROKEN excuse has gone STALE (see below).
set -uo pipefail

FORMULA_DIR="${1:-Formula}"

# Formulae with a known, upstream-unfixable problem (e.g. the release tag is not
# published yet). These are REPORTED as warnings, not failures, so one broken
# upstream doesn't wedge the whole tap's CI.
#
# STALENESS GATE (silent-failure guard): an excuse that never expires is tech
# debt nobody repays. Each entry may carry the date it was added as
#   "name:YYYY-MM-DD"
# Once an entry is older than KNOWN_BROKEN_MAX_AGE_DAYS (default 90) its
# downgrade is revoked: the broken formula becomes a HARD FAILURE again, forcing
# either an upstream fix (delete the entry) or a deliberate re-date. Bare names
# without a date still work but emit a one-time warning asking to be dated.
KNOWN_BROKEN=(
  "saas-churn-predictor:2026-07-03" # upstream v0.1.0 tag not published yet
)
KNOWN_BROKEN_MAX_AGE_DAYS="${KNOWN_BROKEN_MAX_AGE_DAYS:-90}"

# sha256 of GitHub's 9-byte "Not Found" 404 body. A formula carrying this hash
# had its checksum computed against a dead URL instead of a real tarball.
NOT_FOUND_HASH="0019dfc4b32d63c1392aa264aed2253c1e0c2fb09216f8e2cc269bbfb8bb49b5"

# Resolve a KNOWN_BROKEN entry to "known" | "stale" | "undated"; "" if absent.
kb_status() {
  local n="${1}" k name d
  for k in "${KNOWN_BROKEN[@]}"
  do
    name="${k%%:*}"
    [[ ${name} == "${n}" ]] || continue
    d="${k#*:}"
    if [[ ${d} == "${k}" ]]
    then # no ':' -> bare, undated entry
      echo "undated"
      return 0
    fi
    if [[ ! ${d} =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]
    then
      echo "undated"
      return 0
    fi
    local now age_s
    now="$(date -u +%s)"
    # GNU + BSD date portability: parse the fixed-format date ourselves.
    local Y=${d:0:4} M=${d:5:2} D=${d:8:2}
    local then_s
    then_s="$(date -u -j -f '%Y-%m-%d %H:%M:%S' "${Y}-${M}-${D} 00:00:00" +%s 2>/dev/null ||
      date -u -d "${Y}-${M}-${D} 00:00:00" +%s 2>/dev/null ||
      echo "")"
    if [[ -z ${then_s} ]]
    then
      echo "undated"
      return 0
    fi
    age_s=$((now - then_s))
    if ((age_s > KNOWN_BROKEN_MAX_AGE_DAYS * 86400))
    then
      echo "stale"
    else
      echo "known"
    fi
    return 0
  done
  echo ""
}

# Handle a known-broken hit. Sets KB_HANDLED=1 if downgraded (continue caller),
# 0 otherwise (caller must fail).
KB_HANDLED=0
handle_broken() {
  local rb="${1}" name="${2}" kind="${3}" msg="${4}"
  KB_HANDLED=0
  case "${kind}" in
    known)
      echo "::warning file=${rb}::${name}: ${msg} — known-broken (dated), tracked."
      KB_HANDLED=1
      ;;
    undated)
      echo "::warning file=${rb}::${name}: ${msg} — known-broken but UNDATED; add \":YYYY-MM-DD\" to its KNOWN_BROKEN entry so the staleness gate can track it."
      KB_HANDLED=1
      ;;
    stale)
      echo "::error file=${rb}::${name}: ${msg} — AND its KNOWN_BROKEN excuse is STALE (> ${KNOWN_BROKEN_MAX_AGE_DAYS} days). Fix the upstream release and delete the entry, or deliberately re-date it."
      ;;
    *)
      : # unknown kind: caller treats as unhandled (hard failure)
      ;;
  esac
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
    kind="$(kb_status "${name}")"
    if [[ -n ${kind} ]]
    then
      handle_broken "${rb}" "${name}" "${kind}" "sha256 is GitHub's 'Not Found' error-page hash (dead release URL)"
      if ((KB_HANDLED))
      then
        warn=$((warn + 1))
        continue
      fi
      fail=1
      continue
    fi
    echo "::error file=${rb}::${name}: sha256 is GitHub's 'Not Found' error-page hash — the release URL 404s. Recompute from a real tarball."
    fail=1
    continue
  fi

  # 2) Network check: download + compare --------------------------------------
  code="$(curl -sSL --retry 2 --max-time 60 -o "${tmp}" -w '%{http_code}' "${url}" 2>/dev/null || echo 000)"
  if [[ ${code} != "200" ]]
  then
    kind="$(kb_status "${name}")"
    if [[ -n ${kind} ]]
    then
      handle_broken "${rb}" "${name}" "${kind}" "url returned HTTP ${code}: ${url}"
      if ((KB_HANDLED))
      then
        warn=$((warn + 1))
        continue
      fi
      fail=1
      continue
    fi
    echo "::error file=${rb}::${name}: url returned HTTP ${code}: ${url}"
    fail=1
    continue
  fi
  got="$(sha256sum "${tmp}" | cut -d' ' -f1)"
  if [[ ${got} != "${sha}" ]]
  then
    kind="$(kb_status "${name}")"
    if [[ -n ${kind} ]]
    then
      handle_broken "${rb}" "${name}" "${kind}" "sha256 mismatch: have=${sha} real=${got}"
      if ((KB_HANDLED))
      then
        warn=$((warn + 1))
        continue
      fi
      fail=1
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
