#!/bin/sh
set -eu

# Load secrets from Docker secrets if provided
if [ -n "${API_KEY_FILE:-}" ] && [ -f "$API_KEY_FILE" ]; then
  export API_KEY="$(cat "$API_KEY_FILE")"
fi

if [ -n "${PASSWORD_FILE:-}" ] && [ -f "$PASSWORD_FILE" ]; then
  export PASSWORD="$(cat "$PASSWORD_FILE")"
fi

if [ -n "${TOOL_PREFIX:-}" ]; then
  MCP_PACKAGE="${MCP_PACKAGE_NAME:-@chkp/quantum-management-mcp}"
  PREFIX_MARKER="/app/.tool-prefix-applied"
  if [ ! -f "$PREFIX_MARKER" ]; then
    node <<'EOF'
const fs = require("fs");
const path = require.resolve((process.env.MCP_PACKAGE_NAME || "@chkp/quantum-management-mcp") + "/dist/index.js");
const prefix = process.env.TOOL_PREFIX || "";
if (!prefix) process.exit(0);
const marker = "/app/.tool-prefix-applied";
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
EOF
    touch "$PREFIX_MARKER"
  fi
fi

if [ -z "${S1C_URL:-}" ] && [ -z "${MANAGEMENT_HOST:-}" ]; then
  echo "Either S1C_URL or MANAGEMENT_HOST must be provided." >&2
  exit 1
fi

if [ -z "${API_KEY:-}" ]; then
  if [ -z "${USERNAME:-}" ] || [ -z "${PASSWORD:-}" ]; then
    echo "Provide API_KEY or both USERNAME and PASSWORD for authentication." >&2
    exit 1
  fi
fi

PORT_VAL="${PORT:-${MCP_TRANSPORT_PORT:-3012}}"
TRANSPORT_VAL="${MCP_TRANSPORT_TYPE:-http}"

set -- "$@"

# Ensure HTTP transport is configured
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

if [ -n "${S1C_URL:-}" ]; then
  FOUND=false
  for arg in "$@"; do
    if [ "$arg" = "--s1c-url" ]; then
      FOUND=true
      break
    fi
  done
  if [ "$FOUND" = false ]; then
    set -- "$@" "--s1c-url" "$S1C_URL"
  fi
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
    set -- "$@" "--management-port" "$MANAGEMENT_PORT"
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

if [ -n "${USERNAME:-}" ]; then
  FOUND=false
  for arg in "$@"; do
    if [ "$arg" = "--username" ]; then
      FOUND=true
      break
    fi
  done
  if [ "$FOUND" = false ]; then
    set -- "$@" "--username" "$USERNAME"
  fi
fi

if [ -n "${PASSWORD:-}" ]; then
  FOUND=false
  for arg in "$@"; do
    if [ "$arg" = "--password" ]; then
      FOUND=true
      break
    fi
  done
  if [ "$FOUND" = false ]; then
    set -- "$@" "--password" "$PASSWORD"
  fi
fi

exec "$@"
