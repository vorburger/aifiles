#!/usr/bin/env bash
set -euo pipefail

# 1. Install Nix (Determinate Systems installer is recommended for CI/VMs)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm

# 2. Source the Nix profile so 'nix' is available in the current shell
if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

# 3. Ensure the Nix daemon is running (crucial for Docker/Codespaces without systemd)
if [ ! -e /nix/var/nix/daemon-socket/socket ]; then
  echo "Starting nix-daemon..."
  if [ "$(id -u)" -eq 0 ]; then
    /nix/var/nix/profiles/default/bin/nix-daemon > /tmp/nix-daemon.log 2>&1 &
  elif command -v sudo >/dev/null 2>&1; then
    sudo /nix/var/nix/profiles/default/bin/nix-daemon > /tmp/nix-daemon.log 2>&1 &
  else
    echo "Error: need root privileges to start nix-daemon, but 'sudo' is not available." >&2
    echo "Please rerun this script as root or start /nix/var/nix/profiles/default/bin/nix-daemon manually." >&2
    exit 1
  fi
  daemon_pid=$!
  socket_path="/nix/var/nix/daemon-socket/socket"
  timeout=30
  while [ "$timeout" -gt 0 ]; do
    if [ -S "$socket_path" ] || [ -e "$socket_path" ]; then
      break
    fi
    if ! kill -0 "$daemon_pid" 2>/dev/null; then
      echo "nix-daemon failed to start; see /tmp/nix-daemon.log for details." >&2
      exit 1
    fi
    sleep 1
    timeout=$((timeout - 1))
  done
  if [ ! -S "$socket_path" ] && [ ! -e "$socket_path" ]; then
    echo "Timed out waiting for nix-daemon socket at $socket_path" >&2
    exit 1
  fi
fi

# 4. Configure Fish shell for Nix (if fish is installed)
if command -v fish >/dev/null 2>&1; then
  mkdir -p ~/.config/fish/conf.d
  conf_file="${HOME}/.config/fish/conf.d/nix-daemon.fish"
  if [ ! -e "${conf_file}" ]; then
    cat << 'EOF' > "${conf_file}"
if test -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
end
EOF
  fi
fi

# 5. Enable Flakes and the new Nix command
mkdir -p ~/.config/nix
if ! grep -q "experimental-features" ~/.config/nix/nix.conf 2>/dev/null; then
  echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
fi

# 6. Verify the installation
nix --version
nix flake --help
