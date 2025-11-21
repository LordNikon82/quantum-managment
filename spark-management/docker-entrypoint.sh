#!/bin/sh
set -eu

# Load secrets from Docker secrets if provided
if [ -n "${SECRET_KEY_FILE:-}" ] && [ -f "$SECRET_KEY_FILE" ]; then
  export SECRET_KEY="$(cat "$SECRET_KEY_FILE")"
fi

if [ -n "${CLIENT_ID_FILE:-}" ] && [ -f "$CLIENT_ID_FILE" ]; then
  export CLIENT_ID="$(cat "$CLIENT_ID_FILE")"
fi

if [ -n "${INFINITY_PORTAL_URL_FILE:-}" ] && [ -f "$INFINITY_PORTAL_URL_FILE" ]; then
  export INFINITY_PORTAL_URL="$(cat "$INFINITY_PORTAL_URL_FILE")"
fi

if [ -n "${TOOL_PREFIX:-}" ]; then
  MCP_PACKAGE="${MCP_PACKAGE_NAME:-@chkp/spark-management-mcp}"
  PREFIX_MARKER="/app/.tool-prefix-applied"
  if [ ! -f "$PREFIX_MARKER" ]; then
    node <<'EOF_NODE'
const fs = require("fs");
const path = require.resolve((process.env.MCP_PACKAGE_NAME || "@chkp/spark-management-mcp") + "/dist/index.js");
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

if [ -z "${SECRET_KEY:-}" ] || [ -z "${CLIENT_ID:-}" ] || [ -z "${INFINITY_PORTAL_URL:-}" ]; then
  echo "SECRET_KEY, CLIENT_ID, and INFINITY_PORTAL_URL must be provided." >&2
  exit 1
fi

PORT_VAL="${PORT:-${MCP_TRANSPORT_PORT:-3007}}"
TRANSPORT_VAL="${MCP_TRANSPORT_TYPE:-http}"
REGION_VAL="${REGION:-EU}"

set -- "$@"

# Ensure transport is configured
NEEDS_TRANSPORT=true
for arg in "$@"; do
  if [ "$arg" = "--transport" ]; then
    NEEDS_TRANSPORT=false
    break
  fi
done
if [ "$NEEDS_TRANSPORT" = true ]; then
  set -- "$@" "--transport" "$TRANSPORT_VAL"
fi

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

if [ -n "${CLIENT_ID:-}" ]; then
  FOUND=false
  for arg in "$@"; do
    if [ "$arg" = "--client-id" ]; then
      FOUND=true
      break
    fi
  done
  if [ "$FOUND" = false ]; then
    set -- "$@" "--client-id" "$CLIENT_ID"
  fi
fi

if [ -n "${SECRET_KEY:-}" ]; then
  FOUND=false
  for arg in "$@"; do
    if [ "$arg" = "--secret-key" ]; then
      FOUND=true
      break
    fi
  done
  if [ "$FOUND" = false ]; then
    set -- "$@" "--secret-key" "$SECRET_KEY"
  fi
fi

if [ -n "${INFINITY_PORTAL_URL:-}" ]; then
  FOUND=false
  for arg in "$@"; do
    if [ "$arg" = "--infinity-portal-url" ]; then
      FOUND=true
      break
    fi
  done
  if [ "$FOUND" = false ]; then
    set -- "$@" "--infinity-portal-url" "$INFINITY_PORTAL_URL"
  fi
fi

if [ -n "${REGION_VAL:-}" ]; then
  FOUND=false
  for arg in "$@"; do
    if [ "$arg" = "--region" ]; then
      FOUND=true
      break
    fi
  done
  if [ "$FOUND" = false ]; then
    set -- "$@" "--region" "$REGION_VAL"
  fi
fi

exec "$@"
