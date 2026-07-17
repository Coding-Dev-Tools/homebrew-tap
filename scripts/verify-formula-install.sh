#!/usr/bin/env bash
# Static guard: every formula's pip install prefix must be COHERENT with the
# executable it later symlinks into `bin`. Catches the silent-green failure
# class where `brew test-bot --only-tap-syntax` and the checksum verify both
# pass, yet `brew install <formula>` fails at the `install_symlink` step because
# the package was never installed where the symlink points.
#
# Concretely this catches `std_pip_args(prefix: true)`: `true` is not a path, so
# Homebrew interpolates it into `--prefix=true` (a stray relative dir named
# "true"). Nothing lands in libexec, and the next line
# `bin.install_symlink libexec/"bin/<name>"` errors with No such file.
#
# Rule enforced per formula that calls std_pip_args:
#   1. The prefix argument must be a real path keyword (libexec or prefix),
#      never a boolean / quoted literal (true/false/nil/"true").
#   2. The prefix path keyword must match the base dir of the install_symlink
#      source: install into libexec  <->  symlink from libexec/"bin/...".
#   3. A formula that `depends_on "python@3.y"` must install with that
#      dependency's pip (`Formula["python@3.y"].opt_libexec/"bin/pip3"`), NOT the
#      bare `pip3` on PATH. The bare call installs into whichever python the user
#      has (often the system interpreter), so the binary lands outside this
#      formula's libexec/bin and the following install_symlink fails.
#
# Usage: scripts/verify-formula-install.sh [FORMULA_DIR]   (default: Formula)
# Exit 0 if every formula is coherent; 1 if any formula would fail to install.
set -uo pipefail

FORMULA_DIR="${1:-Formula}"
fail=0; okc=0; skip=0

shopt -s nullglob
for rb in "$FORMULA_DIR"/*.rb; do
  name="$(basename "$rb" .rb)"

  # Prefix argument passed to std_pip_args (strip quotes + surrounding space).
  prefix="$(grep -oP 'std_pip_args\(\s*prefix:\s*\K[^),]+' "$rb" | head -1 | tr -d "\"' " | xargs)"
  # Base identifier of the install_symlink source (libexec / prefix / ...).
  symbase="$(grep -oP 'bin\.install_symlink\s+\K[A-Za-z_][A-Za-z_0-9]*' "$rb" | head -1)"

  if [ -z "$prefix" ]; then
    echo "skip: $name (no std_pip_args prefix — nothing to check)"
    skip=$((skip+1)); continue
  fi

  case "$prefix" in
    true|false|nil|True|False|None)
      echo "::error file=$rb::$name: std_pip_args(prefix: $prefix) is not a path — Homebrew interpolates it into '--prefix=$prefix', so nothing installs where the symlink points and 'brew install $name' fails."
      fail=1; continue;;
  esac

  if [ -n "$symbase" ] && [ "$prefix" != "$symbase" ]; then
    echo "::error file=$rb::$name: install prefix ('$prefix') != install_symlink source base ('$symbase'); 'brew install $name' will fail at install_symlink."
    fail=1; continue
  fi

  # 3) Pip-source coherence: a formula that depends_on "python@3.y" but calls the
  #    bare `pip3` on PATH installs into WHICHEVER python the user has (often the
  #    system interpreter, not the declared python@3.y). The package then lands
  #    in that python's bin, not in this formula's libexec/bin, so the next line
  #    `bin.install_symlink libexec/"bin/<name>"` fails with "No such file".
  pydep="$(grep -oP 'depends_on "\Kpython@3\.[0-9]+' "$rb" | head -1)"
  if [ -n "$pydep" ] && grep -qP 'system "pip3"' "$rb"; then
    echo "::error file=$rb::$name: depends_on '$pydep' but installs with the bare \`pip3\` on PATH — 'brew install $name' can fail at install_symlink because the package lands in the wrong python. Use Formula['$pydep'].opt_libexec/\"bin/pip3\"."
    fail=1; continue
  fi

  echo "ok: $name (install prefix=$prefix, symlink base=${symbase:-none})"
  okc=$((okc+1))
done

echo
if [ "$fail" -eq 0 ]; then
  echo "install-lint: PASS — $okc coherent, $skip skipped."
else
  echo "install-lint: FAIL — $okc coherent, $skip skipped, and one or more errors above."
fi
exit $fail
