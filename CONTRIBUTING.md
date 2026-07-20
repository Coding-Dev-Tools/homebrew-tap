# Contributing to Coding-Dev-Tools Homebrew Tap

Thank you for your interest in contributing! This tap provides Homebrew
formulae for the Coding-Dev-Tools suite of developer utilities.

## How to Contribute

### Report Issues
- Open a GitHub issue describing the problem
- Include the formula name, error output, and steps to reproduce
- If a checksum is out of date, include the expected SHA256

### Submit a Formula Fix
1. Fork the repository
2. Create a branch: `git checkout -b fix/<formula-name>-<description>`
3. Update the formula `.rb` file
4. Run the local guards:
   ```bash
   bash scripts/verify-formula-install.sh
   bash scripts/verify-checksums.sh
   ```
5. Open a pull request against `main`
6. Ensure CI passes (includes syntax check, checksum verify, install-lint,
   and guard self-tests)

### Add a New Formula
1. Follow Homebrew's [Formula Cookbook](https://docs.brew.sh/Formula-Cookbook)
2. Place the formula in the `Formula/` directory
3. Verify with the local guards (see above)
4. Submit a pull request

## Code of Conduct
Please note that this project adheres to a [Code of Conduct](CODE_OF_CONDUCT.md).
