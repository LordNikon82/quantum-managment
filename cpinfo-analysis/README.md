# CPInfo Analysis MCP

Docker assets for running the official `@chkp/cpinfo-analysis-mcp` server with HTTP transport.

## Structure

- `Dockerfile` – multi-stage build that installs the published MCP package without leaking registry credentials to the runtime image.
- `docker-compose.yml` – local container definition with healthcheck and optional data volume.
- `docker-entrypoint.sh` – injects transport flags and toggles debug mode from environment variables.
- `.env.example` – suggested runtime configuration for Docker Compose.
- `cpinfo-files/` – placeholder directory you can bind-mount so the container can read CPInfo exports.

## Requirements

- Docker 24+ and Docker Compose v2.
- Access to CPInfo text exports available on the host (mount them into the container).

## Configuration

1. Copy the provided example configuration and adjust it to your environment:

   ```bash
   cp .env.example .env
   $EDITOR .env
   ```

   - `CPINFO_TRANSPORT_PORT` controls the port exposed inside the container (default `3006`).
   - `CPINFO_PUBLISHED_PORT` sets the host port published by Compose; change this when the host port differs from the transport port.
   - Set `MCP_TRANSPORT_TYPE=stdio` if you prefer STDIO transport over HTTP.
   - Toggle `DEBUG` to add the `--debug` CLI flag.
   - `CPINFO_CACHE_TTL_MS` optionally tunes the internal cache eviction window (defaults to 3 hours).
   - `CPINFO_DATA_PATH` should point to a directory containing your extracted CPInfo text files (mounted to `/data`).

2. Build and start the container:

   ```bash
   docker compose up -d --build
   docker logs cpinfo-analysis-official | tail
   ```

You should see: `Check Point CPInfo Analysis MCP Server` and `Transport-port: 3006` (or your configured port).

To stop:

```bash
docker compose down
```

## Using CPInfo files inside the container

Mount the directory that holds your extracted CPInfo text files into the container and reference the in-container path when calling tools. For example, if you place files under `./cpinfo-files` and keep the default volume mapping, the MCP tools can read `/data/my_cpinfo_output.txt`.

## Troubleshooting

- Ensure the mounted directory contains **extracted text files**, not compressed archives. The MCP server does not decompress `.zip` or `.tgz` inputs.
- If the container restarts immediately, verify that your transport port is free and the mounted path exists.
- Increase `CPINFO_CACHE_TTL_MS` if you want to retain parsed CPInfo data for longer idle periods.
