# --- Build stage: install the MCP package ---
FROM node:22-alpine AS build
WORKDIR /app

RUN npm install --omit=dev @chkp/management-logs-mcp

# --- Runtime stage: slim, without tokens/configs ---
FROM node:22-alpine
WORKDIR /app

# Only copy the result—no .npmrc/tokens
COPY --from=build /app/node_modules /app/node_modules

# A small entrypoint that reads secrets from a file (Docker secret)
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENV NODE_ENV=production \
    DEBUG=false \
    MCP_TRANSPORT_TYPE=http \
    MCP_HTTP_PORT=3002 \
    PORT=3002 \
    MANAGEMENT_PORT=443
EXPOSE 3002
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["npx", "@chkp/management-logs-mcp", "--transport-port", "3002"]
