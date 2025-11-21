#!/bin/sh
set -eu

# Load secrets from Docker secrets if provided
if [ -n "${API_KEY_FILE:-}" ] && [ -f "$API_KEY_FILE" ]; then
  export API_KEY="$(cat "$API_KEY_FILE")"
fi

if [ -n "${PASSWORD_FILE:-${GW_PASSWORD_FILE:-}}" ]; then
  FILE_PATH="${PASSWORD_FILE:-${GW_PASSWORD_FILE:-}}"
  if [ -f "$FILE_PATH" ]; then
    export PASSWORD="$(cat "$FILE_PATH")"
  fi
fi

if [ -n "${GW_SSH_KEY_FILE:-}" ] && [ -f "$GW_SSH_KEY_FILE" ]; then
  export GW_SSH_KEY="$(cat "$GW_SSH_KEY_FILE")"
fi

if [ -n "${TOOL_PREFIX:-}" ]; then
  MCP_PACKAGE="${MCP_PACKAGE_NAME:-@chkp/quantum-gw-connection-analysis-mcp}"
  PREFIX_MARKER="/app/.tool-prefix-applied"
  if [ ! -f "$PREFIX_MARKER" ]; then
    node <<'EOF_NODE'
const fs = require("fs");
const path = require.resolve((process.env.MCP_PACKAGE_NAME || "@chkp/quantum-gw-connection-analysis-mcp") + "/dist/index.js");
const prefix = process.env.TOOL_PREFIX || "";
if (!prefix) process.exit(0);
let content = fs.readFileSync(path, "utf8");
const replaced = content.replace(/server\.tool\(\s*"([^"]+)"/g, (match, name) => {
  if (name.startsWith(prefix)) {
    return match;
  }
  return match.replace(`"${name}"`, `"${prefix}${name}"`);
});
if (content !== replaced) {
  fs.writeFileSync(path, replaced, "utf8");
}
EOF_NODE
    touch "$PREFIX_MARKER"
  fi
fi

: "${MANAGEMENT_HOST:?MANAGEMENT_HOST is required}"

PORT_VAL="${PORT:-${MCP_HTTP_PORT:-3005}}"

set -- "$@"

# Ensure transport port flag is present
NEEDS_PORT=true
for arg in "$@"; do
  if [ "$arg" = "--transport-port" ]; then
    NEEDS_PORT=false
    break
  fi
done
if [ "$NEEDS_PORT" = true ]; then
  set -- "$@" "--transport-port" "$PORT_VAL"
fi

if [ -n "${MANAGEMENT_HOST:-}" ]; then
  FOUND=false
  for arg in "$@"; do
    if [ "$arg" = "--management-host" ]; then
      FOUND=true
      break
    fi
  done
  if [ "$FOUND" = false ]; then
    set -- "$@" "--management-host" "$MANAGEMENT_HOST"
  fi
fi

if [ -n "${MANAGEMENT_PORT:-}" ]; then
  FOUND=false
  for arg in "$@"; do
    if [ "$arg" = "--management-port" ]; then
      FOUND=true
      break
    fi
  done
  if [ "$FOUND" = false ]; then
    set -- "$@" "--management-port" "${MANAGEMENT_PORT}"
  fi
fi

if [ -n "${API_KEY:-}" ]; then
  FOUND=false
  for arg in "$@"; do
    if [ "$arg" = "--api-key" ]; then
      FOUND=true
      break
    fi
  done
  if [ "$FOUND" = false ]; then
    set -- "$@" "--api-key" "$API_KEY"
  fi
fi

if [ -n "${CLOUD_INFRA_TOKEN:-}" ]; then
  FOUND=false
  for arg in "$@"; do
    if [ "$arg" = "--cloud-infra-token" ]; then
      FOUND=true
      break
    fi
  done
  if [ "$FOUND" = false ]; then
    set -- "$@" "--cloud-infra-token" "$CLOUD_INFRA_TOKEN"
  fi
fi

USER_VAL="${USERNAME:-${GW_USERNAME:-}}"
if [ -n "$USER_VAL" ]; then
  FOUND=false
  for arg in "$@"; do
    if [ "$arg" = "--username" ]; then
      FOUND=true
      break
    fi
  done
  if [ "$FOUND" = false ]; then
    set -- "$@" "--username" "$USER_VAL"
  fi
fi

PASS_VAL="${PASSWORD:-${GW_PASSWORD:-}}"
if [ -n "$PASS_VAL" ]; then
  FOUND=false
  for arg in "$@"; do
    if [ "$arg" = "--password" ]; then
      FOUND=true
      break
    fi
  done
  if [ "$FOUND" = false ]; then
    set -- "$@" "--password" "$PASS_VAL"
  fi
fi

exec "$@"
