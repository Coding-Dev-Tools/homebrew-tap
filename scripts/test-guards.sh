#!/usr/bin/env bash
# Self-tests for the tap's three silent-failure guards:
#   - scripts/verify-formula-install.sh  (offline, grep-based)
#   - scripts/verify-checksums.sh        (offline-deterministic checks)
#   - scripts/verify-sha-pins.sh         (offline, regex-based)
#
# These guards are the only thing standing between a broken formula and a
# green CI run. If the guards themselves regress, CI must go RED — that is
# what this script enforces. It uses throwaway fixture formulae so it needs
# no network and no `brew`/`ruby`.
#
# Exit 0 = all assertions passed; non-zero = a guard failed to catch a bug
# it claims to catch (i.e. the guard regressed to silent-green).
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${HERE}/.." && pwd)"
VERIFY_INSTALL="${ROOT}/scripts/verify-formula-install.sh"
VERIFY_CHECKSUM="${ROOT}/scripts/verify-checksums.sh"
VERIFY_SHA_PINS="${ROOT}/scripts/verify-sha-pins.sh"

FX="$(mktemp -d)"
CS="$(mktemp -d)"
GOODONLY="$(mktemp -d)"
CSKB="$(mktemp -d)"
SP="$(mktemp -d)"
SP_BAD="$(mktemp -d)"
# shellcheck disable=SC2329
cleanup() {
  # Archive fixtures per AGENTS.md mandate (never delete throwaway test data)
  local archive_dir
  archive_dir="${ROOT}/_tmp/guard-fixtures-$(date +%Y%m%d-%H%M%S)"
  mkdir -p "${archive_dir}" 2>/dev/null || true
  for d in "${FX}" "${CS}" "${GOODONLY}" "${CSKB}" "${SP}" "${SP_BAD}"
  do
    if [[ -d "${d}" ]]
    then
      cp -r "${d}" "${archive_dir}/" 2>/dev/null || true
    fi
  done
  rm -rf "${FX}" "${CS}" "${GOODONLY}" "${CSKB}" "${SP}" "${SP_BAD}"
}
trap cleanup EXIT

pass=0
fail=0
check() { # check <desc> <expected_exit> <actual_exit>
  local desc="$1" exp="$2" act="$3"
  if [[ ${exp} -eq ${act} ]]
  then
    echo "  ok: ${desc} (exit=${act})"
    pass=$((pass + 1))
  else
    echo "  ::error::${desc} - expected exit ${exp} but got ${act} (guard regression / silent-green!)"
    fail=$((fail + 1))
  fi
}

# ---- Fixtures for verify-formula-install.sh (offline) -----------------------
# good: install prefix matches symlink source base -> should PASS
cat >"${FX}/good.rb" <<'RB'
class Good < Formula
  desc "good"
  url "https://example.com/good.tar.gz"
  sha256 "0019dfc4b32d63c1392aa264aed2253c1e0c2fb09216f8e2cc269bbfb8bb49b5"
  def install
    system "pip3", "install", *std_pip_args(prefix: libexec), "."
    bin.install_symlink libexec/"bin/good"
  end
end
RB

# badprefix: std_pip_args(prefix: true) -> Homebrew interpolates --prefix=true -> FAIL
cat >"${FX}/badprefix.rb" <<'RB'
class Badprefix < Formula
  desc "badprefix"
  url "https://example.com/badprefix.tar.gz"
  sha256 "0019dfc4b32d63c1392aa264aed2253c1e0c2fb09216f8e2cc269bbfb8bb49b5"
  def install
    system "pip3", "install", *std_pip_args(prefix: true), "."
    bin.install_symlink libexec/"bin/badprefix"
  end
end
RB

# mismatch: installs into libexec but symlinks from prefix -> FAIL
cat >"${FX}/mismatch.rb" <<'RB'
class Mismatch < Formula
  desc "mismatch"
  url "https://example.com/mismatch.tar.gz"
  sha256 "0019dfc4b32d63c1392aa264aed2253c1e0c2fb09216f8e2cc269bbfb8bb49b5"
  def install
    system "pip3", "install", *std_pip_args(prefix: libexec), "."
    bin.install_symlink prefix/"bin/mismatch"
  end
end
RB

echo "verify-formula-install.sh:"
"${VERIFY_INSTALL}" "${FX}" >/dev/null 2>&1
check "catches badprefix + mismatch (no clean tree)" 1 $?
# a dir with only the good fixture must pass
cp "${FX}/good.rb" "${GOODONLY}/"
"${VERIFY_INSTALL}" "${GOODONLY}" >/dev/null 2>&1
check "passes a coherent formula" 0 $?

# ---- Fixtures for verify-checksums.sh (offline-deterministic paths) ---------
# malformed: sha256 is not 64 hex -> must FAIL (no network needed)
cat >"${CS}/malformed.rb" <<'RB'
class Malformed < Formula
  url "https://example.com/malformed.tar.gz"
  sha256 "zzzz-not-a-real-hash"
end
RB

# notfound: carries GitHub's 404-page hash, NOT in KNOWN_BROKEN -> must FAIL
cat >"${CS}/notfound.rb" <<'RB'
class Notfound < Formula
  url "https://example.com/notfound.tar.gz"
  sha256 "0019dfc4b32d63c1392aa264aed2253c1e0c2fb09216f8e2cc269bbfb8bb49b5"
end
RB

# knownbroken: same 404-page hash but name is in KNOWN_BROKEN -> downgrade to warning, exit 0
cat >"${CS}/saas-churn-predictor.rb" <<'RB'
class SaasChurnPredictor < Formula
  url "https://example.com/saas-churn-predictor.tar.gz"
  sha256 "0019dfc4b32d63c1392aa264aed2253c1e0c2fb09216f8e2cc269bbfb8bb49b5"
end
RB

echo "verify-checksums.sh (offline paths):"
"${VERIFY_CHECKSUM}" "${CS}" >/dev/null 2>&1
check "fails on malformed hash + 404-page hash (known-broken downgraded)" 1 $?
# KNOWN_BROKEN only: same 404 hash but the guard must NOT fail the build
cp "${CS}/saas-churn-predictor.rb" "${CSKB}/"
"${VERIFY_CHECKSUM}" "${CSKB}" >/dev/null 2>&1
check "downgrades KNOWN_BROKEN 404-hash to a warning (exit 0)" 0 $?

# KNOWN_BROKEN staleness gate: dated entries expire after
# KNOWN_BROKEN_MAX_AGE_DAYS and their downgrade is revoked (hard FAIL).
kbfx() { # kbfx <dir> <formula-name>
  cat >"${1}/${2}.rb" <<RB
class Kbplaceholder < Formula
  url "https://example.com/${2}.tar.gz"
  sha256 "0019dfc4b32d63c1392aa264aed2253c1e0c2fb09216f8e2cc269bbfb8bb49b5"
end
RB
}
run_kb() { # run_kb <dir> <entry> <maxage>  -> exit code of verify-checksums.sh
  local sedvc
  sedvc="$(mktemp)"
  sed "s|\"saas-churn-predictor:2026-07-03\".*|\"${2}\"|; s|KNOWN_BROKEN_MAX_AGE_DAYS:-90|KNOWN_BROKEN_MAX_AGE_DAYS:-${3}|" "${VERIFY_CHECKSUM}" >"${sedvc}"
  bash "${sedvc}" "${1}" >/dev/null 2>&1
  local rc=$?
  rm -f "${sedvc}"
  return "${rc}"
}

# ---- Fixtures for verify-sha-pins.sh (offline, regex-based) -----------------
# pinned: all uses: directives have 40-char SHA -> should PASS
cat >"${SP}/ci.yml" <<'YML'
name: CI
on: [push]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@11d5960a326750d5838078e36cf38b85af677262  # v4.4.0
      - uses: actions/setup-python@a26af69be951a213d495a4c3e4e4022e16d87065  # v5.6.0
YML

# unpinned: uses @v4 mutable tag -> must FAIL
cat >"${SP_BAD}/ci.yml" <<'YML'
name: CI
on: [push]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
YML

echo "verify-sha-pins.sh:"
bash "${VERIFY_SHA_PINS}" "${SP}" >/dev/null 2>&1
check "passes when all uses: are SHA-pinned" 0 $?
bash "${VERIFY_SHA_PINS}" "${SP_BAD}" >/dev/null 2>&1
check "fails when uses: has mutable tag (@v4)" 1 $?

# ---- KNOWN_BROKEN staleness gate (offline, deterministic path only) ---------
KB1="$(mktemp -d)"
KB2="$(mktemp -d)"
KB3="$(mktemp -d)"
kbfx "${KB1}" fx
kbfx "${KB2}" fx
kbfx "${KB3}" fx
TODAY="$(date -u +%F)"
echo "verify-checksums.sh KNOWN_BROKEN staleness gate:"
run_kb "${KB1}" "fx:${TODAY}" 90
check "fresh dated KNOWN_BROKEN entry still downgrades" 0 $?
run_kb "${KB2}" "fx" 90
check "undated KNOWN_BROKEN entry still downgrades (with nag)" 0 $?
run_kb "${KB3}" "fx:2026-01-01" 90
check "STALE dated KNOWN_BROKEN entry becomes a hard failure" 1 $?

echo
# ---- livecheck coverage ------------------------------------------------------
# Every formula must carry a `livecheck` stanza so `brew livecheck` can detect
# upstream releases; a formula without one silently goes stale.
echo "livecheck coverage guard:"
LC_FAIL=0
for formula in "$ROOT"/Formula/*.rb
do
  if ! grep -q "livecheck do" "$formula"
  then
    echo "::error file=Formula/$(basename "${formula}")::missing livecheck stanza"
    LC_FAIL=1
  fi
done
check "every formula has a livecheck stanza" 0 "${LC_FAIL}"

if [[ ${fail} -eq 0 ]]
then
  echo "guard-tests: PASS - ${pass} assertion(s) ok."
  exit 0
else
  echo "guard-tests: FAIL - ${fail} assertion(s) failed, ${pass} ok."
  exit 1
fi
