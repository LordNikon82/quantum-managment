FROM node:22-alpine AS build
WORKDIR /app

RUN set -eux; \
    npm install --omit=dev \
      @chkp/quantum-management-mcp \
      @chkp/quantum-gw-cli-mcp \
      @chkp/management-logs-mcp

FROM node:22-alpine
WORKDIR /app

COPY --from=build /app/node_modules /app/node_modules

COPY quantum-management/docker-entrypoint.sh /usr/local/bin/mgmt-entrypoint.sh
COPY quantum-gw-cli/docker-entrypoint.sh /usr/local/bin/gw-entrypoint.sh
COPY quantum-management-logs/docker-entrypoint.sh /usr/local/bin/logs-entrypoint.sh
COPY suite/entrypoint.sh /usr/local/bin/suite-entrypoint.sh

RUN chmod +x \
      /usr/local/bin/mgmt-entrypoint.sh \
      /usr/local/bin/gw-entrypoint.sh \
      /usr/local/bin/logs-entrypoint.sh \
      /usr/local/bin/suite-entrypoint.sh

ENV NODE_ENV=production \
    DEBUG=false

EXPOSE 3002 3003 3012

ENTRYPOINT ["suite-entrypoint.sh"]
