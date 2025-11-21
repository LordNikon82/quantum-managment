FROM node:22-alpine AS build
WORKDIR /app

ARG NPM_REGISTRY=https://registry.npmjs.org/
ARG JFROG_MCP_ACCESS_TOKEN=

RUN set -eux; \
    if [ -n "$JFROG_MCP_ACCESS_TOKEN" ]; then \
      npm config set //registry.npmjs.org/:_authToken "$JFROG_MCP_ACCESS_TOKEN"; \
    fi; \
    npm install --omit=dev --registry="$NPM_REGISTRY" @chkp/quantum-gaia-mcp

FROM node:22-alpine
WORKDIR /app

COPY --from=build /app/node_modules /app/node_modules

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENV NODE_ENV=production \
    DEBUG=false \
    VERBOSE=false \
    MCP_TRANSPORT_TYPE=http \
    MCP_HTTP_PORT=3000 \
    PORT=3000

EXPOSE 3000
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["npx", "@chkp/quantum-gaia-mcp"]
