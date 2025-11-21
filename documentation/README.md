# Check Point Documentation Tool MCP

Docker assets for running the official `@chkp/documentation-mcp` server with HTTP transport.

## Structure

- `Dockerfile` – multi-stage build that installs the published MCP package without leaking registry credentials to the runtime image.
- `docker-compose.yml` – local container definition with secrets and healthcheck.
- `docker-entrypoint.sh` – injects transport flags and credentials from environment variables or Docker secrets.
- `.env.example` – suggested runtime configuration for Docker Compose.
- `secrets/` – placeholders for storing the Documentation Tool `CLIENT_ID` and `SECRET_KEY`.

## Requirements

- Docker 24+ and Docker Compose v2.
- Connectivity from the container to the Documentation Tool endpoint in the chosen region.

## Configuration

1. Copy the example environment file and edit it for your setup:

   ```bash
   cp .env.example .env
   $EDITOR .env
   ```

   - `CLIENT_ID` and `SECRET_KEY` are required for Documentation Tool authentication.
   - `REGION` controls which Documentation Tool region to target (EU, US, STG, Local). Defaults to `EU`.
   - `DOCUMENTATION_TRANSPORT_PORT` sets the port exposed inside the container (default `3000`).
   - `DOCUMENTATION_PUBLISHED_PORT` sets the host port published by Compose. Override this if you need a different host port.
   - Set `MCP_TRANSPORT_TYPE=stdio` if you prefer STDIO transport instead of HTTP.
   - Toggle `DEBUG=true` to add the `--debug` flag at startup.

2. (Optional) Store credentials in Docker secrets instead of environment variables. Update the files in `secrets/` and ensure Compose can read them. Secrets are read into `CLIENT_ID` and `SECRET_KEY` at container start.

3. Build and start the container:

   ```bash
   docker compose up -d --build
   docker logs documentation-official | tail
   ```

   You should see the MCP server listening on port `3000` (or your configured transport port).

To stop the container:

```bash
docker compose down
```

## Custom Port

To expose a different host port, update both:

- `DOCUMENTATION_TRANSPORT_PORT` and `DOCUMENTATION_PUBLISHED_PORT` in your `.env` file.
- The `ports` mapping in `docker-compose.yml` if you prefer to hard-code the values instead of using environment variables.
