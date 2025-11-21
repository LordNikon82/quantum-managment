# Quantum Gaia MCP

Docker assets for running the official `@chkp/quantum-gaia-mcp` server with HTTP transport.

## Structure

- `Dockerfile` – multi-stage build that installs the published MCP package without leaking registry credentials to the runtime image.
- `docker-compose.yml` – local container definition with healthcheck.
- `docker-entrypoint.sh` – injects transport flags and toggles debug/verbose modes from environment variables.
- `.env.example` – suggested runtime configuration for Docker Compose.

## Requirements

- Docker 24+ and Docker Compose v2.
- Network access from the container to the target Gaia gateway (default port `443`).

## Configuration

1. Copy the provided example configuration and adjust it to your environment:

   ```bash
   cp .env.example .env
   $EDITOR .env
   ```

   - `GAIA_TRANSPORT_PORT` controls the port exposed inside the container (default `3000`).
   - `GAIA_PUBLISHED_PORT` sets the host port published by Compose; change this when the host port differs from the transport port.
   - Set `MCP_TRANSPORT_TYPE=stdio` if you prefer STDIO transport over HTTP.
   - Toggle `DEBUG` or `VERBOSE` to add the corresponding CLI flags.

2. Build and start the container:

   ```bash
   docker compose up -d --build
   docker logs quantum-gaia-official | tail
   ```

You should see: `Check Point GAIA API MCP Server with dialog authentication` and `Transport-port: 3000` (or your configured port).

To stop:

```bash
docker compose down
```

## Custom Port

To expose a different host port, update both:

- `GAIA_TRANSPORT_PORT` and `GAIA_PUBLISHED_PORT` in `.env`.
- `ports` mapping in `docker-compose.yml` if you prefer to hard-code it instead of using the environment variable.

## Authentication Notes

`@chkp/quantum-gaia-mcp` uses interactive, dialog-based authentication. Credentials are supplied through your MCP client when the server prompts for them; no Docker secrets are required for this image.
