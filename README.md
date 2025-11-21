# Quantum MCP Servers

Docker assets for running the official Check Point Quantum MCP servers.

## Repositories

- [`quantum-management/`](quantum-management/README.md) – Quantum Management MCP server.
- [`spark-management/`](spark-management/README.md) – Spark Management MCP server.
- [`quantum-gw-cli/`](quantum-gw-cli/README.md) – Quantum Gateway CLI MCP server.
- [`quantum-gw-connection-analysis/`](quantum-gw-connection-analysis/README.md) – Quantum Gateway Connection Analysis MCP server.
- [`quantum-management-logs/`](quantum-management-logs/README.md) – Quantum Management Logs MCP server.
- [`quantum-gaia/`](quantum-gaia/README.md) – Quantum Gaia MCP server.
- [`cpinfo-analysis/`](cpinfo-analysis/README.md) – CPInfo Analysis MCP server.
- [`documentation/`](documentation/README.md) – Documentation Tool MCP server.
- [`threat-prevention/`](threat-prevention/README.md) – Threat Prevention MCP server.

Each directory contains its own Dockerfile, Compose definition, entrypoint script, and (where applicable) secrets placeholders. Consult the individual READMEs for configuration and usage instructions.

## All-in-one suite

The repository also includes a consolidated configuration for running every official MCP server inside a single container, located in [`suite/`](suite/). The setup consists of:

- `suite/Dockerfile` – builds an image that installs `@chkp/quantum-management-mcp`, `@chkp/quantum-gw-cli-mcp`, and `@chkp/management-logs-mcp` into the same runtime.
- `suite/entrypoint.sh` – orchestrates the three entrypoint scripts and keeps them supervised.
- `suite/docker-compose.yml` – convenience compose file for building and running the combined container.
- `suite/.env` – shared environment configuration consumed by the compose file.
- `suite/secrets/quantum-mcp-suite.secrets` – consolidated secret placeholders for credentials shared by the suite.

### Quick start

1. Populate `suite/secrets/quantum-mcp-suite.secrets` with the appropriate credentials (API keys, passwords, etc.).
2. Adjust `suite/.env` to match your environment (hosts, usernames, published ports, etc.).
3. Build and start the stack from the repository root:

   ```bash
   docker compose -f suite/docker-compose.yml up --build -d
   ```

### Configuration

- Toggle services with `ENABLE_MANAGEMENT`, `ENABLE_GW_CLI`, and `ENABLE_LOGS` (all default to `true`).
- Shared variables (`MANAGEMENT_HOST`, `MANAGEMENT_PORT`, `USERNAME`, `CLOUD_INFRA_TOKEN`, `S1C_URL`) cascade into each service unless you provide a service-specific override (e.g. `GW_MANAGEMENT_HOST`, `MGMT_USERNAME`).
- Port overrides are available per service via `MGMT_TRANSPORT_PORT`, `GW_TRANSPORT_PORT`, and `LOGS_TRANSPORT_PORT`; the compose file publishes each service on the matching `${SERVICE}_PUBLISHED_PORT` value.
- Secrets are read from the consolidated Docker secret file and written to per-service files at runtime, so existing entrypoints continue to receive the expected file-based credentials.

See [`suite/docker-compose.yml`](suite/docker-compose.yml) for the full list of supported environment variables.
