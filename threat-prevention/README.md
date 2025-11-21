# Threat Prevention MCP

Docker assets for running the official `@chkp/threat-prevention-mcp` server with HTTP transport.

## Structure

- `Dockerfile` – multi-stage build that installs the published MCP package without leaking registry credentials to the runtime image.
- `docker-compose.yml` – local container definition with healthcheck.
- `docker-entrypoint.sh` – injects transport flags and toggles debug mode from environment variables.

## Requirements

- Docker 24+ and Docker Compose v2.

## Configuration

1. Create an environment file (optional) with your preferred ports and settings:

   ```bash
   cat <<'ENV' > .env
   THREAT_PREVENTION_TRANSPORT_PORT=3008
   THREAT_PREVENTION_PUBLISHED_PORT=3008
   MCP_TRANSPORT_TYPE=http
   DEBUG=false
   ENV
   ```

2. Build and start the container:

   ```bash
   docker compose up -d --build
   docker logs threat-prevention-official | tail
   ```

   You should see logs from `@chkp/threat-prevention-mcp` indicating the configured transport port.

To stop the container, run:

```bash
docker compose down
```

## Troubleshooting

- If the container restarts immediately, ensure the chosen port is free on the host.
- Switch `MCP_TRANSPORT_TYPE` to `stdio` when you want STDIO transport instead of HTTP.
- Set `DEBUG=true` to pass the `--debug` flag to the MCP server.
