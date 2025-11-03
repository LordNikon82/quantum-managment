# --- Build stage: holt das Paket mit Registry-Token ---
FROM node:22-alpine AS build
WORKDIR /app

ARG NPM_REGISTRY="https://registry.npmjs.org/"
ARG JFROG_MCP_ACCESS_TOKEN

# Nur wenn Registry + Token vorhanden → temporär in diesem Stage setzen
RUN npm config set registry "${NPM_REGISTRY}" \
 && if [ -n "${JFROG_MCP_ACCESS_TOKEN}" ]; then \
      REGISTRY_DOMAIN="$(echo "${NPM_REGISTRY}" | sed 's|https\?://||;s|/$||')" && \
      npm config set "//${REGISTRY_DOMAIN}:_authToken" "${JFROG_MCP_ACCESS_TOKEN}"; \
    fi \
 && npm cache clean --force \
 && npm install --omit=dev @chkp/management-logs-mcp \
 && if [ -n "${JFROG_MCP_ACCESS_TOKEN}" ]; then \
      REGISTRY_DOMAIN="$(echo "${NPM_REGISTRY}" | sed 's|https\?://||;s|/$||')" && \
      npm config delete "//${REGISTRY_DOMAIN}:_authToken"; \
    fi

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
