#!/usr/bin/env bash
set -euo pipefail

# ==========================================
# ssherve - Interactive SSH connection tool
# ==========================================

VERSION="main"
CONFIG_DIR="$HOME/.config/ssherve"
CONFIG_FILE="$CONFIG_DIR/servers.json"
UPDATE_URL="https://api.github.com/repos/cl3tus/ssherve/releases/latest"
INSTALL_CMD="curl -fsSL https://raw.githubusercontent.com/cl3tus/ssherve/main/install.sh | bash"

# ------------------------------------------
# Utility functions
# ------------------------------------------

error() { echo "Error: $*" >&2; exit 1; }

# Ensure required binaries are available
require_deps() {
  for dep in jq fzf; do
    command -v "$dep" >/dev/null 2>&1 || error "$dep is required (install via apt, brew, or pacman)"
  done
}

# Ensure config file exists, create an example if not
ensure_config() {
  if [[ -f "$CONFIG_FILE" ]]; then
    return
  fi

  echo "No configuration found at $CONFIG_FILE"
  echo "Creating an example configuration..."
  mkdir -p "$CONFIG_DIR"

  cat >"$CONFIG_FILE" <<EOF
{
  "servers": [
    {
      "name": "Example Server",
      "ip": "192.168.1.10",
      "user": "admin",
      "port": 22,
      "identity": "~/.ssh/id_rsa"
    }
  ]
}
EOF

  echo "Example configuration created."
}

# ------------------------------------------
# Version and update handling
# ------------------------------------------

show_version() {
  echo "ssherve v$VERSION"
}

check_for_updates() {
  local force="${1:-false}"
  local last_check_file="$CONFIG_DIR/.last_update_check"
  local now
  local last_check=0
  
  now=$(date +%s)

  # Check only once every 7 days, unless forced
  if [[ "$force" != "true" && -f "$last_check_file" ]]; then
    last_check=$(<"$last_check_file")
    if (( now - last_check < 604800 )); then
      return
    fi
  fi

  echo "$now" >"$last_check_file"

  echo "Checking for updates..."
  local latest_version
  latest_version=$(curl -fsSL "$UPDATE_URL" | jq -r '.tag_name' 2>/dev/null || true)

  if [[ -z "$latest_version" || "$latest_version" == "null" ]]; then
    echo "Unable to check for updates."
    return
  fi

  if [[ "$latest_version" != "v$VERSION" ]]; then
    echo
    echo "A new version is available: $latest_version"
    echo "Update with:"
    echo "  $INSTALL_CMD"
    echo
  else
    echo "You are running the latest version ($VERSION)."
  fi
}

# ------------------------------------------
# Server selection and SSH connection
# ------------------------------------------

load_servers() {
  local count
  count=$(jq '.servers | length' "$CONFIG_FILE")
  (( count > 0 )) || error "No servers found in $CONFIG_FILE"

  for i in $(seq 0 $((count - 1))); do
    local name ip user port identity display_user display_identity
    name=$(jq -r ".servers[$i].name" "$CONFIG_FILE")
    ip=$(jq -r ".servers[$i].ip" "$CONFIG_FILE")
    user=$(jq -r ".servers[$i].user // empty" "$CONFIG_FILE")
    port=$(jq -r ".servers[$i].port // 22" "$CONFIG_FILE")
    identity=$(jq -r ".servers[$i].identity // empty" "$CONFIG_FILE")
    display_user="${user:+$user@}"
    display_identity="${identity:+ (key: $(basename "$identity"))}"
    echo "$i | ${name} — ${display_user}${ip}:${port}${display_identity}"
  done
}

select_server() {
  local servers selected index
  mapfile -t servers < <(load_servers)

  selected=$(printf '%s\n' "${servers[@]}" | fzf \
    --prompt="Select a server > " \
    --height=~10 \
    --border=rounded \
    --info=inline-right \
    --layout=reverse \
    --ansi)

  [[ -n "$selected" ]] || { echo "No server selected."; exit 0; }

  index=$(echo "$selected" | cut -d '|' -f 1 | tr -d ' ')
  connect_to_server "$index"
}

connect_to_server() {
  local index="$1"
  local ip user port identity identity_expanded target
  ip=$(jq -r ".servers[$index].ip" "$CONFIG_FILE")
  user=$(jq -r ".servers[$index].user // empty" "$CONFIG_FILE")
  port=$(jq -r ".servers[$index].port // 22" "$CONFIG_FILE")
  identity=$(jq -r ".servers[$index].identity // empty" "$CONFIG_FILE")

  local cmd=(ssh)
  [[ "$port" != "22" ]] && cmd+=("-p" "$port")

  if [[ -n "$identity" ]]; then
    identity_expanded="${identity/#\~/$HOME}"
    cmd+=("-i" "$identity_expanded")
  fi

  target="${ip}"
  [[ -n "$user" ]] && target="${user}@${ip}"
  cmd+=("$target")

  echo "Connecting to $target..."
  sleep 0.3
  exec "${cmd[@]}"
}

# ------------------------------------------
# Main execution flow
# ------------------------------------------

main() {
  require_deps
  ensure_config

  case "${1:-}" in
    --version|-v)
      show_version
      exit 0
      ;;
    --check-update)
      check_for_updates true
      exit 0
      ;;
  esac

  check_for_updates
  select_server
}

main "$@"
