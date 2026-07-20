# Tests

This directory contains tests for the `coding-dev-tools/homebrew-tap` formulae.

## Test Suites

- **`test-guards.sh`** — Self-tests for the formula integrity guards
  (`scripts/verify-formula-install.sh` and `scripts/verify-checksums.sh`).
  Run via: `bash scripts/test-guards.sh`

## Running Tests

```bash
# Run the formula integrity guard self-tests
bash scripts/test-guards.sh
```

All tests are designed to run offline with no network or Homebrew dependency,
using throwaway fixture formulae.
