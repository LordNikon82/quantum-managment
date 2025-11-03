# Quantum Gateway CLI MCP

Docker assets for running the official `@chkp/quantum-gw-cli-mcp` server with HTTP transport.

## Structure

- `Dockerfile` – multi-stage build that installs the published MCP package with optional private registry support.
- `docker-compose.yml` – local container definition with healthcheck and Docker secrets wiring.
- `docker-entrypoint.sh` – injects CLI flags, prefixes tool names, and loads secrets at runtime.
- `secrets/*.txt` – placeholders for API key/password secret files consumed by Docker secrets.
- `.env` – runtime configuration loaded by Docker Compose (create manually).

## Requirements

- Docker 24+ and Docker Compose v2.
- Network access from the container to the target Security Management server.
- API key or username/password (stored as Docker secrets).

## Configuration

1. Create a `.env` file inside this directory (`quantum-gw-cli/.env`) if it does not already exist. Start from the snippet below and adjust values to your environment:
   ```dotenv
   # Gateway CLI transport port configuration
   GW_CLI_TRANSPORT_PORT=3003
   GW_CLI_PUBLISHED_PORT=3003

   # Target Management
   MANAGEMENT_HOST=your-mgmt-hostname
   MANAGEMENT_PORT=443

   # Optional authentication helpers
   GW_CLI_USERNAME=your-admin-username
   # Leave GW_CLI_USERNAME blank when using API key auth only

   # Optional extras
   GW_CLI_TOOL_PREFIX=gw-cli__
   GW_CLI_CLOUD_INFRA_TOKEN=
   DEBUG=false
   ```
   - `GW_CLI_TRANSPORT_PORT` controls the port exposed inside the container (default `3003`).
   - `GW_CLI_PUBLISHED_PORT` sets the host port published by Compose; change when the host port differs from the transport port.
   - `MANAGEMENT_HOST`/`MANAGEMENT_PORT` target the on-prem management server.
   - Set `GW_CLI_USERNAME` and the password secret when using username/password authentication.
2. Populate Docker secrets with your credentials:
   - `secrets/gw_cli_api_key.txt` for API-key authentication.
   - `secrets/gw_cli_password.txt` when using username/password. (Leave empty or delete if unused.)

## Usage

```bash
cd quantum-gw-cli

# ensure secrets contain the correct values
$EDITOR secrets/gw_cli_api_key.txt
$EDITOR secrets/gw_cli_password.txt

docker compose up -d --build
docker logs quantum-gw-cli-official | tail
```

You should see: `Quantum GW CLI MCP server running on HTTP transport ... Transport-port: 3003` (or your configured port).

To stop:

```bash
docker compose down
```

## Custom Port

To expose a different host port, update both:

- `GW_CLI_TRANSPORT_PORT` and `GW_CLI_PUBLISHED_PORT` in `.env`.
- `ports` mapping in `docker-compose.yml` if you prefer to hard-code it instead of using the environment variable.

## Troubleshooting

- Container restarts immediately: ensure the secrets files exist and `.env` provides `MANAGEMENT_HOST`.
- Healthcheck fails: ensure the configured transport port is free and the management endpoint is reachable.
