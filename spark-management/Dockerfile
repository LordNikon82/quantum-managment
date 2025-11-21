FROM node:22-alpine AS build
WORKDIR /app

RUN npm install --omit=dev @chkp/spark-management-mcp

FROM node:22-alpine
WORKDIR /app

COPY --from=build /app/node_modules /app/node_modules
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# MCP_PORT defines the transport/listening port for the MCP server and defaults to 3007.
ARG MCP_PORT=3007
ENV NODE_ENV=production \
    DEBUG=false \
    MCP_TRANSPORT_TYPE=http \
    MCP_TRANSPORT_PORT=${MCP_PORT} \
    MCP_PUBLISHED_PORT=${MCP_PORT} \
    PORT=${MCP_PORT} \
    REGION=EU

EXPOSE ${MCP_PORT}

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["npx", "@chkp/spark-management-mcp"]
