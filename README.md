# DevForge Homebrew Tap

Homebrew formulas for **DevForge** developer CLI tools — installable via:

```bash
brew install Coding-Dev-Tools/homebrew-tap/<formula>
```

## Development workflow

```bash
brew tap Coding-Dev-Tools/homebrew-tap
brew install <formula>
<tool> --help
```

## Maintainers / Contributors

Submit formula changes against the `main` branch.

## Available Formulas

| Formula | Description |
|---------|-------------|
| `api-contract-guardian` | Monitor OpenAPI schema diffs, detect breaking changes |
| `apiauth` | API key and JWT lifecycle management with an encrypted local store |
| `apighost` | Spawn a realistic mock API server from an OpenAPI spec, with VCR record/replay |
| `click-to-mcp` | Convert any Click/Typer CLI into an MCP server automatically |
| `configdrift` | Track and detect configuration drift across environments |
| `datamorph` | Batch convert between data formats (CSV, JSON, YAML, Parquet, Avro, Protobuf) |
| `deadcode` | Detect unused exports, dead routes, and orphaned CSS in TS/React/Next.js |
| `deploydiff` | Compare deployment manifests across environments |
| `envault` | Env variable syncing, diffing, and secret rotation CLI |
| `json2sql-cli` | Convert JSON files to SQL CREATE TABLE and INSERT statements |
| `schemaforge` | Bidirectional ORM schema converter |

> **Temporarily unavailable:** `saas-churn-predictor` — its upstream release tag is not
> published yet, so the formula cannot be installed. It is tracked as known-broken in
> [`scripts/verify-checksums.sh`](./scripts/verify-checksums.sh) and will be restored once the
> release exists.

## Quick Start

```bash
# Add the tap
brew tap Coding-Dev-Tools/homebrew-tap

# Install any formula
brew install schemaforge

# Verify
schemaforge --help
```

## Formula integrity

Every formula pins a release tarball by `sha256`. If that checksum is wrong — or was
computed against a 404 error page instead of a real tarball — `brew install` fails even
though the Ruby syntax is perfectly valid. To catch that class of breakage, CI runs
[`scripts/verify-checksums.sh`](./scripts/verify-checksums.sh), which downloads each
formula's `url` and confirms the recorded `sha256` matches (and that the URL resolves).

Run it locally before opening a PR that touches a formula:

```bash
bash scripts/verify-checksums.sh Formula
```

### Guard self-tests

The two guards above are themselves tested, because a guard that silently
stops catching broken formulae would keep CI green while broken formulae
ship. [`scripts/test-guards.sh`](./scripts/test-guards.sh) builds throwaway
fixture formulae (no network / `brew` / `ruby` needed) and asserts each guard
catches the bug class it claims to catch. It runs as the `guard-tests` CI job
and turns the build RED on any guard regression.

```bash
bash scripts/test-guards.sh
```

## License

MIT — see [LICENSE](./LICENSE).
