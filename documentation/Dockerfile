# --- Build stage: fetch documentation MCP package ---
FROM node:22-alpine AS build
WORKDIR /app

RUN npm install --omit=dev @chkp/documentation-mcp

# --- Runtime stage: lean image without registry credentials ---
FROM node:22-alpine
WORKDIR /app

COPY --from=build /app/node_modules /app/node_modules

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENV NODE_ENV=production \
    DEBUG=false \
    MCP_TRANSPORT_TYPE=http \
    MCP_HTTP_PORT=3000 \
    MCP_TRANSPORT_PORT=3000 \
    PORT=3000 \
    REGION=EU

EXPOSE 3000
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["npx", "@chkp/documentation-mcp"]
