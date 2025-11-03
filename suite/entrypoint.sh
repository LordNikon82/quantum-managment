#!/bin/sh
set -eu

SUITE_SECRETS_FILE_PATH="${SUITE_SECRETS_FILE:-/run/secrets/quantum_suite_secrets}"
SUITE_SECRET_STAGE_DIR="/tmp/quantum-suite-secrets"

load_suite_secrets() {
  if [ ! -f "$SUITE_SECRETS_FILE_PATH" ]; then
    return
  fi

  set +u
  set -a
  # shellcheck source=/dev/null
  . "$SUITE_SECRETS_FILE_PATH"
  set +a
  set -u
}

get_var_value() {
  var_name="$1"
  eval "printf '%s' \"\${$var_name:-}\""
}

resolve_secret_file() {
  value_var="$1"
  file_var="$2"
  default_path="$3"
  staged_name="$4"

  value="$(get_var_value "$value_var")"
  if [ -n "$value" ]; then
    mkdir -p "$SUITE_SECRET_STAGE_DIR"
    staged_path="$SUITE_SECRET_STAGE_DIR/$staged_name"
    printf '%s' "$value" > "$staged_path"
    chmod 600 "$staged_path"
    echo "$staged_path"
    return
  fi

  explicit_path="$(get_var_value "$file_var")"
  if [ -n "$explicit_path" ] && [ -f "$explicit_path" ]; then
    echo "$explicit_path"
    return
  fi

  if [ -f "$default_path" ]; then
    echo "$default_path"
    return
  fi

  echo ""
}

load_suite_secrets

pids=""
service_names=""

register_pid() {
  pid="$1"
  name="$2"
  if [ -z "$pids" ]; then
    pids="$pid"
  else
    pids="$pids $pid"
  fi
  if [ -z "$service_names" ]; then
    service_names="$name:$pid"
  else
    service_names="$service_names $name:$pid"
  fi
}

stop_all() {
  for pid in $pids; do
    if kill -0 "$pid" 2>/dev/null; then
      kill "$pid" 2>/dev/null || true
    fi
  done
}

await_shutdown() {
  for pid in $pids; do
    if kill -0 "$pid" 2>/dev/null; then
      wait "$pid" 2>/dev/null || true
    fi
  done
}

trap 'stop_all; await_shutdown; exit 0' INT TERM

start_management() {
  (
    export MCP_PACKAGE_NAME="@chkp/quantum-management-mcp"
    export MCP_TRANSPORT_TYPE="${MGMT_TRANSPORT_TYPE:-http}"
    export MCP_TRANSPORT_PORT="${MGMT_TRANSPORT_PORT:-3012}"
    export MCP_PUBLISHED_PORT="${MGMT_PUBLISHED_PORT:-${MGMT_TRANSPORT_PORT:-3012}}"
    export PORT="${MGMT_TRANSPORT_PORT:-3012}"
    export TOOL_PREFIX="${MGMT_TOOL_PREFIX:-mgmt__}"
    export MANAGEMENT_HOST="${MGMT_MANAGEMENT_HOST:-${MANAGEMENT_HOST:-}}"
    export MANAGEMENT_PORT="${MGMT_MANAGEMENT_PORT:-${MANAGEMENT_PORT:-443}}"
    export S1C_URL="${MGMT_S1C_URL:-${S1C_URL:-}}"
    export USERNAME="${MGMT_USERNAME:-${USERNAME:-}}"
    password_file="$(resolve_secret_file "MGMT_PASSWORD" "MGMT_PASSWORD_FILE" "/run/secrets/mgmt_password" "mgmt_password")"
    if [ -n "$password_file" ]; then
      export PASSWORD_FILE="$password_file"
    else
      unset PASSWORD_FILE
    fi
    api_key_file="$(resolve_secret_file "MGMT_API_KEY" "MGMT_API_KEY_FILE" "/run/secrets/mgmt_api_key" "mgmt_api_key")"
    if [ -n "$api_key_file" ]; then
      export API_KEY_FILE="$api_key_file"
    else
      unset API_KEY_FILE
    fi
    export CLOUD_INFRA_TOKEN="${MGMT_CLOUD_INFRA_TOKEN:-${CLOUD_INFRA_TOKEN:-}}"
    exec /usr/local/bin/mgmt-entrypoint.sh npx @chkp/quantum-management-mcp
  ) &
  register_pid "$!" "management"
}

start_gateway_cli() {
  (
    export MCP_PACKAGE_NAME="@chkp/quantum-gw-cli-mcp"
    export MCP_TRANSPORT_TYPE="http"
    export MCP_HTTP_PORT="${GW_TRANSPORT_PORT:-3003}"
    export PORT="${GW_TRANSPORT_PORT:-3003}"
    export TOOL_PREFIX="${GW_TOOL_PREFIX:-${GW_CLI_TOOL_PREFIX:-gw-cli__}}"
    export MANAGEMENT_HOST="${GW_MANAGEMENT_HOST:-${MANAGEMENT_HOST:-}}"
    export MANAGEMENT_PORT="${GW_MANAGEMENT_PORT:-${MANAGEMENT_PORT:-443}}"
    export USERNAME="${GW_USERNAME:-${GW_CLI_USERNAME:-${USERNAME:-}}}"
    password_file="$(resolve_secret_file "GW_PASSWORD" "GW_PASSWORD_FILE" "/run/secrets/gw_cli_password" "gw_cli_password")"
    if [ -n "$password_file" ]; then
      export PASSWORD_FILE="$password_file"
    else
      unset PASSWORD_FILE
    fi
    api_key_file="$(resolve_secret_file "GW_API_KEY" "GW_API_KEY_FILE" "/run/secrets/gw_cli_api_key" "gw_cli_api_key")"
    if [ -n "$api_key_file" ]; then
      export API_KEY_FILE="$api_key_file"
    else
      unset API_KEY_FILE
    fi
    export CLOUD_INFRA_TOKEN="${GW_CLOUD_INFRA_TOKEN:-${CLOUD_INFRA_TOKEN:-}}"
    export GW_SSH_KEY_FILE="${GW_SSH_KEY_FILE:-}"
    exec /usr/local/bin/gw-entrypoint.sh npx @chkp/quantum-gw-cli-mcp
  ) &
  register_pid "$!" "gateway-cli"
}

start_logs() {
  (
    export MCP_PACKAGE_NAME="@chkp/management-logs-mcp"
    export MCP_TRANSPORT_TYPE="http"
    export MCP_HTTP_PORT="${LOGS_TRANSPORT_PORT:-3002}"
    export PORT="${LOGS_TRANSPORT_PORT:-3002}"
    export TOOL_PREFIX="${LOGS_TOOL_PREFIX:-logs__}"
    export MANAGEMENT_HOST="${LOGS_MANAGEMENT_HOST:-${MANAGEMENT_HOST:-}}"
    export MANAGEMENT_PORT="${LOGS_MANAGEMENT_PORT:-${MANAGEMENT_PORT:-443}}"
    api_key_file="$(resolve_secret_file "LOGS_API_KEY" "LOGS_API_KEY_FILE" "/run/secrets/logs_api_key" "logs_api_key")"
    if [ -n "$api_key_file" ]; then
      export API_KEY_FILE="$api_key_file"
    else
      unset API_KEY_FILE
    fi
    exec /usr/local/bin/logs-entrypoint.sh npx @chkp/management-logs-mcp --transport-port "${LOGS_TRANSPORT_PORT:-3002}"
  ) &
  register_pid "$!" "management-logs"
}

if [ "${ENABLE_MANAGEMENT:-true}" = "true" ]; then
  start_management
fi

if [ "${ENABLE_GW_CLI:-true}" = "true" ]; then
  start_gateway_cli
fi

if [ "${ENABLE_LOGS:-true}" = "true" ]; then
  start_logs
fi

if [ -z "$pids" ]; then
  echo "No MCP services enabled. Set at least one of ENABLE_MANAGEMENT, ENABLE_GW_CLI, or ENABLE_LOGS to true." >&2
  exit 1
fi

wait_for_failure() {
  status=0
  failed_pid=""
  while :; do
    for pid in $pids; do
      if ! kill -0 "$pid" 2>/dev/null; then
        set +e
        wait "$pid" 2>/dev/null
        status=$?
        set -e
        failed_pid="$pid"
        return $status
      fi
    done
    sleep 1
  done
}

wait_for_failure
exit_code=$?

for entry in $service_names; do
  pid="${entry#*:}"
  name="${entry%%:*}"
  if [ "$pid" = "$failed_pid" ]; then
    echo "Service '$name' exited with status $exit_code" >&2
    break
  fi
fi

stop_all
await_shutdown
exit $exit_code
