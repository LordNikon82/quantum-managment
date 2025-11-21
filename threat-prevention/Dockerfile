# --- Build stage: fetch threat-prevention package ---
FROM node:22-alpine AS build
WORKDIR /app

RUN npm install --omit=dev @chkp/threat-prevention-mcp

# --- Runtime stage: lean image without registry credentials ---
FROM node:22-alpine
WORKDIR /app

COPY --from=build /app/node_modules /app/node_modules

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENV NODE_ENV=production \
    DEBUG=false \
    MCP_TRANSPORT_TYPE=http \
    MCP_HTTP_PORT=3008 \
    MCP_TRANSPORT_PORT=3008 \
    MCP_PUBLISHED_PORT=3008 \
    PORT=3008

EXPOSE 3008
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["npx", "@chkp/threat-prevention-mcp"]
