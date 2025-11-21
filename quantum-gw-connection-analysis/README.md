# Quantum Gateway Connection Analysis MCP

Docker assets for running the official `@chkp/quantum-gw-connection-analysis-mcp` server with HTTP transport.

## Structure

- `Dockerfile` – multi-stage build that installs the published MCP package.
- `docker-compose.yml` – local container definition with healthcheck and Docker secrets wiring.
- `docker-entrypoint.sh` – injects CLI flags, prefixes tool names, and loads secrets at runtime.
- `secrets/*.txt` – placeholders for API key/password secret files consumed by Docker secrets.
- `.env` – runtime configuration loaded by Docker Compose (copy from `.env.example`).

## Requirements

- Docker 24+ and Docker Compose v2.
- Network access from the container to the target Security Management server.
- API key or username/password (stored as Docker secrets).

## Configuration

1. Copy the provided example configuration and adjust it to your environment:
   ```bash
   cp .env.example .env
   $EDITOR .env
   ```
   - `GW_CA_TRANSPORT_PORT` controls the port exposed inside the container (default `3005`).
   - `GW_CA_PUBLISHED_PORT` sets the host port published by Compose; change when the host port differs from the transport port.
   - `MANAGEMENT_HOST`/`MANAGEMENT_PORT` target the on-prem management server.
   - Set `GW_CA_USERNAME` and the password secret when using username/password authentication. Leave it blank when using API-key only auth.
2. Populate Docker secrets with your credentials:
   - `secrets/gw_ca_api_key.txt` for API-key authentication.
   - `secrets/gw_ca_password.txt` when using username/password. (Leave empty or delete if unused.)

## Usage

```bash
cd quantum-gw-connection-analysis

# ensure secrets contain the correct values
$EDITOR secrets/gw_ca_api_key.txt
$EDITOR secrets/gw_ca_password.txt

docker compose up -d --build
docker logs quantum-gw-connection-analysis-official | tail
```

You should see: `Quantum GW Connection Analysis MCP server running on HTTP transport ... Transport-port: 3005` (or your configured port).

To stop:

```bash
docker compose down
```

## Custom Port

To expose a different host port, update both:

- `GW_CA_TRANSPORT_PORT` and `GW_CA_PUBLISHED_PORT` in `.env`.
- `ports` mapping in `docker-compose.yml` if you prefer to hard-code it instead of using the environment variable.

## Troubleshooting

- Container restarts immediately: ensure the secrets files exist and `.env` provides `MANAGEMENT_HOST`.
- Healthcheck fails: ensure the configured transport port is free and the management endpoint is reachable.
