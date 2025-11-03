#!/bin/sh
set -eu

# Secret aus Datei einlesen (Docker Secret)
if [ -n "${API_KEY_FILE:-}" ] && [ -f "$API_KEY_FILE" ]; then
  export API_KEY="$(cat "$API_KEY_FILE")"
fi

if [ -n "${TOOL_PREFIX:-}" ]; then
  MCP_PACKAGE="${MCP_PACKAGE_NAME:-@chkp/management-logs-mcp}"
  PREFIX_MARKER="/app/.tool-prefix-applied"
  if [ ! -f "$PREFIX_MARKER" ]; then
    node <<'EOF_NODE'
const fs = require("fs");
const path = require.resolve((process.env.MCP_PACKAGE_NAME || "@chkp/management-logs-mcp") + "/dist/index.js");
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

# Minimal-Validierung
: "${MANAGEMENT_HOST:?MANAGEMENT_HOST is required (e.g. 192.168.2.230)}"
: "${API_KEY:?API_KEY (or API_KEY_FILE) is required}"

if [ -z "${PORT:-}" ] && [ -n "${MCP_HTTP_PORT:-}" ]; then
  export PORT="${MCP_HTTP_PORT}"
fi

# Optional: Wenn dein MCP CLI-Flags braucht, statt ENV:
# exec npx @chkp/management-logs-mcp \
#   --management-host "$MANAGEMENT_HOST" \
#   --management-port "${MANAGEMENT_PORT:-443}"

exec "$@"
