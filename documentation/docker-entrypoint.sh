#!/bin/sh
set -eu

if [ -n "${CLIENT_ID_FILE:-}" ] && [ -f "$CLIENT_ID_FILE" ]; then
  export CLIENT_ID="$(cat "$CLIENT_ID_FILE")"
fi

if [ -n "${SECRET_KEY_FILE:-}" ] && [ -f "$SECRET_KEY_FILE" ]; then
  export SECRET_KEY="$(cat "$SECRET_KEY_FILE")"
fi

if [ -z "${CLIENT_ID:-}" ]; then
  echo "CLIENT_ID is required" >&2
  exit 1
fi

if [ -z "${SECRET_KEY:-}" ]; then
  echo "SECRET_KEY is required" >&2
  exit 1
fi

TRANSPORT="${MCP_TRANSPORT_TYPE:-http}"
PORT_VAL="${PORT:-${MCP_HTTP_PORT:-${MCP_TRANSPORT_PORT:-3000}}}"
REGION_VAL="${REGION:-EU}"

set -- "$@"

needs_flag() {
  flag="$1"
  shift
  for arg in "$@"; do
    if [ "$arg" = "$flag" ]; then
      return 1
    fi
  done
  return 0
}

if needs_flag "--transport" "$@"; then
  set -- "$@" "--transport" "$TRANSPORT"
fi

if needs_flag "--transport-port" "$@"; then
  set -- "$@" "--transport-port" "$PORT_VAL"
fi

if needs_flag "--client-id" "$@"; then
  set -- "$@" "--client-id" "$CLIENT_ID"
fi

if needs_flag "--secret-key" "$@"; then
  set -- "$@" "--secret-key" "$SECRET_KEY"
fi

if needs_flag "--region" "$@"; then
  set -- "$@" "--region" "$REGION_VAL"
fi

if [ "${DEBUG:-false}" = "true" ] && needs_flag "--debug" "$@"; then
  set -- "$@" "--debug"
fi

exec "$@"
