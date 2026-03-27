#!/usr/bin/env bash
set -euo pipefail

# 1. Install Nix (Determinate Systems installer is recommended for CI/VMs)
# Check if nix is already available in the PATH or in the default profile
if ! command -v nix >/dev/null 2>&1 && [ ! -e /nix/var/nix/profiles/default/bin/nix ]; then
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm
fi

# 2. Find and source Nix
# Source the Nix profile so 'nix' is available in the current shell
if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
  # shellcheck source=/dev/null
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

# Set NIX_BIN for use in starting the daemon if needed
NIX_BIN=$(command -v nix || echo "/nix/var/nix/profiles/default/bin/nix")

if [ ! -x "$NIX_BIN" ]; then
  echo "Error: nix binary not found or not executable at $NIX_BIN." >&2
  false
fi

# 3. Configure Nix
# Detect if we need to disable sandboxing/seccomp (common in restricted environments like some CI/VMs)
# Nix sandboxing requires unprivileged user namespaces.
CAN_SANDBOX=false
if unshare --user --map-root-user true 2>/dev/null; then
  CAN_SANDBOX=true
elif [ -f /proc/sys/kernel/apparmor_restrict_unprivileged_userns ] && [ "$(cat /proc/sys/kernel/apparmor_restrict_unprivileged_userns)" = "1" ]; then
  # On modern systems like Ubuntu 24.04+, unprivileged userns are restricted by default.
  # We try to enable it if we have sudo privileges.
  echo "Info: Attempting to enable unprivileged user namespaces via sysctl..."
  if sudo sysctl -w kernel.apparmor_restrict_unprivileged_userns=0 >/dev/null 2>&1 && unshare --user --map-root-user true 2>/dev/null; then
    CAN_SANDBOX=true
  fi
fi

sudo mkdir -p /etc/nix
if [ "$CAN_SANDBOX" = "true" ]; then
  echo "Info: Unprivileged user namespaces are supported. Nix sandboxing will remain enabled (default)."
  # Ensure the custom config is empty if sandboxing is supported
  sudo tee /etc/nix/nix.custom.conf > /dev/null << 'CONF'
# Nix sandboxing remains enabled because unprivileged user namespaces are supported.
CONF
else
  echo "Warning: Unprivileged user namespaces are NOT supported. Disabling Nix sandboxing and syscall filtering."
  cat << 'CONF' | sudo tee /etc/nix/nix.custom.conf > /dev/null
sandbox = false
filter-syscalls = false
CONF
fi

if ! grep -q "experimental-features" /etc/nix/nix.conf 2>/dev/null; then
  echo "extra-experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf > /dev/null
fi

# 4. Start Daemon
if [ ! -e /nix/var/nix/daemon-socket/socket ]; then
  sudo pkill nix-daemon || true
  sudo "$NIX_BIN-daemon" 2>&1 | sudo tee /tmp/nix-daemon.log > /dev/null &
  sleep 2
fi

# 5. Export Path
PATH="$(dirname "$NIX_BIN"):$PATH"
export PATH

# 6. Verify the installation
nix --version
nix flake --help > /dev/null
echo "Nix installation and configuration complete."
