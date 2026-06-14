# DevForge Homebrew Tap

Homebrew formulas for **DevForge** developer CLI tools — installable via `brew install Coding-Dev-Tools/homebrew-tap/<formula>`.

## Available Formulas

| Formula | Description |
|---------|-------------|
| `configdrift` | Track and detect configuration drift across environments |
| `api-contract-guardian` | Monitor OpenAPI schema diffs, detect breaking changes |
| `click-to-mcp` | Convert any Click/Typer CLI into an MCP server automatically |
| `deadcode` | Detect unused exports, dead routes, and orphaned CSS in TS/React/Next.js |
| `datamorph` | Batch convert between data formats (CSV, JSON, YAML, Parquet, Avro, Protobuf) |
| `deploydiff` | Compare deployment manifests across environments |
| `envault` | Env variable syncing, diffing, and secret rotation CLI |
| `json2sql-cli` | Convert JSON files to SQL CREATE TABLE and INSERT statements |
| `schemaforge` | Bidirectional ORM schema converter |
| `saas-churn-predictor` | SaaS churn prediction with sklearn pipelines |

## Quick Start

```bash
# Add the tap
brew tap Coding-Dev-Tools/homebrew-tap

# Install any formula
brew install schemaforge

# Verify
schemaforge --help
```

## License

MIT — see [LICENSE](./LICENSE).
