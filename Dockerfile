FROM node:22-alpine AS build
WORKDIR /app

RUN npm install --omit=dev @chkp/quantum-management-mcp

FROM node:22-alpine
WORKDIR /app

COPY --from=build /app/node_modules /app/node_modules
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# MCP_PORT defines the transport/listening port for the MCP server and defaults to 3012.
ARG MCP_PORT=3012
ENV NODE_ENV=production \
    DEBUG=false \
    MCP_TRANSPORT_TYPE=http \
    MCP_TRANSPORT_PORT=${MCP_PORT} \
    PORT=${MCP_PORT} \
    MANAGEMENT_PORT=443

EXPOSE ${MCP_PORT}

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["npx", "@chkp/quantum-management-mcp"]
