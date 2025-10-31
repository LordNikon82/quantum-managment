# Quantum Management MCP (Official Build)

Docker assets for running the official `@chkp/quantum-management-mcp` server with HTTP transport.

## Structure

  - `Dockerfile` – production image.
  - `docker-compose.yml` – container definition with healthcheck.
  - `docker-entrypoint.sh` – injects CLI flags and loads secrets.
  - `secrets/*.txt` – placeholders for API key/password.
  - `.env` – sample configuration.

## Requirements

- Docker 24+ and Docker Compose v2.
- Node-compatible network access to Check Point Management or Smart-1 Cloud.
- API key or username/password (stored as Docker secrets).

## Configuration

1. Copy `.env` and adjust:
   - `MANAGEMENT_HOST` / `MANAGEMENT_PORT` for on-prem.
   - Optional `S1C_URL` if you use Smart-1 Cloud.
   - `MCP_TRANSPORT_PORT` in `docker-compose.yml` if you need a different port (default `3012`).
2. Place secrets in:
   - `ImagewEntrypoint/secrets/cp_api_key.txt`
   - `ImagewEntrypoint/secrets/mgmt_password.txt` (only when using username/password).
3. Optional registry access:
   - Set `NPM_REGISTRY` / `JFROG_MCP_ACCESS_TOKEN` (or other token) via environment or compose overrides.

## Usage

```bash
cd ImagewEntrypoint
docker compose up -d --build
docker logs quantum-management-official | tail
```

The log should show: `Management MCP server running on HTTP transport ... Transport-port: 3012`.

To stop:

```bash
docker compose down
```

## Custom Port

To expose a different host port, update both:

- `MCP_TRANSPORT_PORT` and `ports` mapping in `docker-compose.yml`.
- Optional environment overrides (e.g. `export MCP_TRANSPORT_PORT=3100` before `docker compose up`).

## Troubleshooting

- Container restarts immediately: check secrets exist and `.env` provides either `S1C_URL` or `MANAGEMENT_HOST`.
- Healthcheck fails: ensure port isn’t already in use and the management endpoint is reachable.
- Registry errors: verify registry URL/token and rerun `docker compose build`.

