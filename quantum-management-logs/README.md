# Management Logs MCP

Docker assets for running the official `@chkp/management-logs-mcp` server with HTTP transport.

## Structure

- `Dockerfile` – multi-stage build that installs the MCP package without requiring registry tokens.
- `docker-compose.yml` – docker-compose definition with healthcheck and secret mounting.
- `docker-entrypoint.sh` – loads secrets, optionally prefixes tool names, and validates required env vars.
- `secrets/*.txt` – placeholders for API keys and other confidential values.

## Requirements

- Docker 24+ and Docker Compose v2.
- Network access from the container to the Check Point management endpoint.
- API key stored as a Docker secret.

## Configuration

1. Review the provided `.env` file and adjust values such as `MANAGEMENT_HOST`, `MANAGEMENT_PORT`, or transport port values for your environment.
2. Populate the secret file with your API key:
   ```bash
   $EDITOR secrets/cp_api_key.txt
   ```
3. (Optional) Set `TOOL_PREFIX` to avoid tool name collisions when running multiple MCP servers.

## Usage

```bash
cd quantum-management-logs

docker compose up -d --build
```

Check logs to verify startup:

```bash
docker logs management-logs-official | tail
```

## Troubleshooting

- Container exits immediately: ensure `MANAGEMENT_HOST` and the API key secret are set.
- Healthcheck fails: confirm port `3002` is free on the host or adjust the `ports` mapping.
