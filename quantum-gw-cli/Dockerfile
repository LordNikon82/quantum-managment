# --- Build stage: fetch gw-cli package ---
FROM node:22-alpine AS build
WORKDIR /app

RUN npm install --omit=dev @chkp/quantum-gw-cli-mcp

# --- Runtime stage: lean image without registry credentials ---
FROM node:22-alpine
WORKDIR /app

COPY --from=build /app/node_modules /app/node_modules

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENV NODE_ENV=production \
    DEBUG=false \
    MCP_TRANSPORT_TYPE=http \
    MCP_HTTP_PORT=3003 \
    PORT=3003

EXPOSE 3003
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["npx", "@chkp/quantum-gw-cli-mcp"]
