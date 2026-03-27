#!/usr/bin/env bash
set -euo pipefail

# 1. Install Nix (Determinate Systems installer is recommended for CI/VMs)
if [ ! -d /nix/store ]; then
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm || true
fi

# 2. Find and source Nix
NIX_BIN=""
if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  NIX_BIN=$(command -v nix || echo "")
fi

if [ -z "$NIX_BIN" ]; then
  NIX_BIN=$(find /nix/store -name nix -type f -executable | head -n 1 || echo "")
fi

if [ -z "$NIX_BIN" ]; then
  echo "Error: nix binary not found." >&2
  false
fi

# 3. Configure Nix
# Minimal configuration for environments where seccomp/sandboxing is restricted.
# We leverage the '!include nix.custom.conf' already in the default Determinate nix.conf.
sudo mkdir -p /etc/nix
cat << 'CONF' | sudo tee /etc/nix/nix.custom.conf > /dev/null
sandbox = false
filter-syscalls = false
