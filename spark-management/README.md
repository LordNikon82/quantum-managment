# Spark Management MCP

Docker assets for running the official `@chkp/spark-management-mcp` server with HTTP transport.

## Structure

- `Dockerfile` – production image.
- `docker-compose.yml` – container definition with healthcheck.
- `docker-entrypoint.sh` – injects CLI flags, prefixes tool names, and loads secrets.
- `secrets/*.txt` – placeholders for client ID and secret key.
- `.env.example` – starter configuration for Docker Compose.

## Requirements

- Docker 24+ and Docker Compose v2.
- Connectivity to the configured Infinity Portal endpoint.
- Spark Management API client ID and secret key (stored as Docker secrets).

## Configuration

1. Copy the example environment and adjust it to your deployment:
   ```bash
   cd spark-management
   cp .env.example .env
   $EDITOR .env
   ```
   - `SPARK_TRANSPORT_PORT` controls the port exposed inside the container (default `3007`).
   - `SPARK_PUBLISHED_PORT` sets the host port published by Compose; change this when the host port differs from the transport port.
   - `CLIENT_ID` and `INFINITY_PORTAL_URL` come from the Spark Management API credentials page.
   - `REGION` defaults to `EU`; valid values are `EU`, `US`, `STG`, or `LOCAL`.
2. Populate Docker secrets with your credentials:
   - `secrets/spark_secret_key.txt` for the API secret key.
   - `secrets/spark_client_id.txt` for the client ID (optional if provided via environment).

## Usage

```bash
cd spark-management

# ensure secrets contain the correct values
$EDITOR secrets/spark_secret_key.txt
$EDITOR secrets/spark_client_id.txt

docker compose up -d --build
docker logs spark-management-official | tail
```

You should see: `Spark Management MCP server running on HTTP transport ... Transport-port: 3007` (or your configured port).

To stop:

```bash
docker compose down
```

## Custom Port

To expose a different host port, update both:

- `SPARK_TRANSPORT_PORT` and `SPARK_PUBLISHED_PORT` in `.env`.
- `ports` mapping in `docker-compose.yml` if you prefer to hard-code it instead of using the environment variable.

## Troubleshooting

- Container restarts immediately: ensure the secrets files exist and `.env` provides `CLIENT_ID`, `INFINITY_PORTAL_URL`, and `REGION`.
- Healthcheck fails: ensure the configured transport port is free and the Infinity Portal endpoint is reachable.
