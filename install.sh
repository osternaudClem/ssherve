#!/usr/bin/env bash
set -euo pipefail

# ==========================================
# ssherve - Installation Script
# ==========================================

INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="$HOME/.config/ssherve"
CONFIG_FILE="$CONFIG_DIR/servers.json"
REPO_URL="https://raw.githubusercontent.com/osternaudClem/ssherve/main"
SCRIPT_URL="$REPO_URL/ssherve.sh"

# ------------------------------------------
# Utility functions
# ------------------------------------------

error() {
  echo "Error: $*" >&2
  exit 1
}

info() {
  echo "-- $*"
}

# ------------------------------------------
# Dependency installation
# ------------------------------------------

install_dependency() {
  local dep="$1"

  if command -v "$dep" >/dev/null 2>&1; then
    return
  fi

  info "Installing missing dependency: $dep"

  if command -v apt >/dev/null 2>&1; then
    sudo apt update -y && sudo apt install -y "$dep"
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --noconfirm "$dep"
  elif command -v brew >/dev/null 2>&1; then
    brew install "$dep"
  else
    error "Cannot install $dep automatically. Please install it manually."
  fi
}

check_dependencies() {
  for dep in curl jq fzf; do
    install_dependency "$dep"
  done
}

# ------------------------------------------
# Installation logic
# ------------------------------------------

install_script() {
  sudo mkdir -p "$INSTALL_DIR"

  info "Downloading ssherve..."
  if ! sudo curl -fsSL "$SCRIPT_URL" -o "$INSTALL_DIR/ssherve"; then
    error "Unable to download ssherve.sh from $REPO_URL"
  fi

  sudo chmod +x "$INSTALL_DIR/ssherve"
}

create_config() {
  mkdir -p "$CONFIG_DIR"

  if [[ -f "$CONFIG_FILE" ]]; then
    info "Existing configuration detected: $CONFIG_FILE"
    return
  fi

  info "Creating example configuration..."
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
  info "Example configuration created at $CONFIG_FILE"
}

# ------------------------------------------
# Main execution
# ------------------------------------------

main() {
  echo "Installing ssherve..."

  check_dependencies
  install_script
  create_config

  echo
  echo "ssherve installed successfully."
  echo
  echo "Usage:"
  echo "  ssherve            # open interactive SSH selector"
  echo
  echo "Configuration file:"
  echo "  $CONFIG_FILE"
  echo
}

main "$@"
