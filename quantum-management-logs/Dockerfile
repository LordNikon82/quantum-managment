# --- Build stage: installiert das MCP-Paket ---
FROM node:22-alpine AS build
WORKDIR /app

RUN npm install --omit=dev @chkp/management-logs-mcp

# --- Runtime stage: schlank, ohne Token/Configs ---
FROM node:22-alpine
WORKDIR /app

# Nur das Ergebnis übernehmen – keine .npmrc/Token
COPY --from=build /app/node_modules /app/node_modules

# Ein kleiner EntryPoint, der Secrets aus Datei liest (Docker Secret)
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
