# Changelog

All notable changes to this Homebrew tap will be documented in this file.

## [Unreleased]
### Fixed
- Fixed shfmt formatting violations in `scripts/verify-formula-install.sh`
- Added CONTRIBUTING.md, CODE_OF_CONDUCT.md, CHANGELOG.md, tests/

## [2026-07-19]
### Changed
- Fixed broken Python install prefix in all 12 formulae
- Added `install-lint` guard
- Standardized Python dependency to `python@3.10`

## [2026-07-13] - Initial release
### Added
- Initial 12 Homebrew formulae for Coding-Dev-Tools CLI utilities
- CI pipeline with `brew test-bot --only-tap-syntax`
- Checksum verification via `scripts/verify-checksums.sh`
