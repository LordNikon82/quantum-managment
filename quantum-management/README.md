# Quantum Management MCP

Docker assets for running the official `@chkp/quantum-management-mcp` server with HTTP transport.

## Structure

- `Dockerfile` – production image.
- `docker-compose.yml` – container definition with healthcheck.
- `docker-entrypoint.sh` – injects CLI flags and loads secrets.
- `secrets/*.txt` – placeholders for API key/password.
- `.env` – runtime configuration loaded by Compose (create manually).

## Requirements

- Docker 24+ and Docker Compose v2.
- Network access from the container to Check Point Management or Smart-1 Cloud.
- API key or username/password (stored as Docker secrets).

## Configuration

1. Create a `.env` file in this directory (`quantum-management/.env`) if it does not already exist. Start from the snippet below and adjust values to your environment:
   ```dotenv
   # Management connection (choose either on-prem host/port or Smart-1 Cloud URL)
   MANAGEMENT_HOST=your-mgmt-hostname
   MANAGEMENT_PORT=443
   # S1C_URL=https://api.smart-1-cloud.example

   # Credentials
   USERNAME=your-admin-username
   # Leave USERNAME blank when using API key auth only

   # Networking
   MCP_TRANSPORT_PORT=3012
   MCP_PUBLISHED_PORT=3012

   # Optional extras
   # DEBUG=true
   ```
   - `MANAGEMENT_HOST` / `MANAGEMENT_PORT` target on-prem gateways.
   - `S1C_URL` is only required for Smart-1 Cloud deployments.
   - `MCP_TRANSPORT_PORT` controls the port exposed inside the container (default `3012`).
   - `MCP_PUBLISHED_PORT` sets the host port published by Compose; set this when the host port differs from the transport port.
2. Populate Docker secrets with your credentials:
   - `secrets/cp_api_key.txt` for API-key authentication.
   - `secrets/mgmt_password.txt` when using username/password. (Leave empty or delete if unused.)

## Usage

```bash
cd quantum-management

# ensure secrets contain the correct values
$EDITOR secrets/cp_api_key.txt
$EDITOR secrets/mgmt_password.txt

docker compose up -d --build
docker logs quantum-management-official | tail
```

The log should show: `Management MCP server running on HTTP transport ... Transport-port: 3012` (or your configured port).

To stop:

```bash
docker compose down
```

## Custom Port

To expose a different host port, update both:

- `MCP_TRANSPORT_PORT` and `MCP_PUBLISHED_PORT` in `.env`.
- `ports` mapping in `docker-compose.yml` if you prefer to hard-code it instead of using the environment variable.

## Troubleshooting

- Container restarts immediately: ensure the secrets files exist and `.env` provides either `S1C_URL` or `MANAGEMENT_HOST`.
- Healthcheck fails: ensure the configured transport port is free and the management endpoint is reachable.
