# Changelog

All notable changes to this Homebrew tap will be documented in this file.

## [Unreleased]

### Fixed
- Fixed `shfmt` formatting violations in `scripts/verify-formula-install.sh`
  (`then`/`do` on separate lines, `|` spacing, arithmetic spacing,
  compound-command splitting)
- Added `tests/` directory, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`,
  and `CHANGELOG.md` to meet release-audit standards

## [2026-07-19] - PR #10

### Changed
- Fixed broken Python install prefix in all 12 formulae
- Added `install-lint` guard (`scripts/verify-formula-install.sh`)
- Standardized Python dependency to `python@3.10` throughout
- Added `pip` declaration to match declared `python@3.10` dependency
  in all formulae

## [2026-07-13] - Initial tap release

### Added
- Initial 12 Homebrew formulae for Coding-Dev-Tools CLI utilities
- CI pipeline with `brew test-bot --only-tap-syntax`
- Checksum verification via `scripts/verify-checksums.sh`
- `KNOWN_BROKEN` mechanism for temporarily unavailable releases
