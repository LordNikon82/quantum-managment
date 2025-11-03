FROM node:22-alpine AS build
WORKDIR /app

ARG NPM_REGISTRY="https://registry.npmjs.org/"
ARG JFROG_MCP_ACCESS_TOKEN

RUN npm config set registry "${NPM_REGISTRY}" \
 && if [ -n "${JFROG_MCP_ACCESS_TOKEN}" ]; then \
      REGISTRY_DOMAIN="$(echo "${NPM_REGISTRY}" | sed 's|https\?://||;s|/$||')" && \
      npm config set "//${REGISTRY_DOMAIN}:_authToken" "${JFROG_MCP_ACCESS_TOKEN}"; \
    fi \
 && npm cache clean --force \
 && npm install --omit=dev @chkp/quantum-management-mcp \
 && if [ -n "${JFROG_MCP_ACCESS_TOKEN}" ]; then \
      REGISTRY_DOMAIN="$(echo "${NPM_REGISTRY}" | sed 's|https\?://||;s|/$||')" && \
      npm config delete "//${REGISTRY_DOMAIN}:_authToken"; \
    fi

FROM node:22-alpine
WORKDIR /app

COPY --from=build /app/node_modules /app/node_modules
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENV NODE_ENV=production \
    DEBUG=false \
    MCP_TRANSPORT_TYPE=http \
    MCP_TRANSPORT_PORT=3012 \
    PORT=3012 \
    MANAGEMENT_PORT=443

EXPOSE 3012

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["npx", "@chkp/quantum-management-mcp"]
