#!/bin/sh
set -eu

TRANSPORT="${MCP_TRANSPORT_TYPE:-http}"
PORT_VAL="${PORT:-${MCP_HTTP_PORT:-${MCP_TRANSPORT_PORT:-3009}}}"

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

if [ "${DEBUG:-false}" = "true" ] && needs_flag "--debug" "$@"; then
  set -- "$@" "--debug"
fi

exec "$@"
