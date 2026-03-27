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
sudo mkdir -p /etc/nix
cat << 'CONF' | sudo tee /etc/nix/nix.custom.conf > /dev/null
sandbox = false
filter-syscalls = false
substituters = https://cache.nixos.org https://install.determinate.systems
trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM=
CONF

if ! grep -q "experimental-features" /etc/nix/nix.conf 2>/dev/null; then
  echo "extra-experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf > /dev/null
fi

# 4. Start Daemon
if [ ! -e /nix/var/nix/daemon-socket/socket ]; then
  sudo pkill nix-daemon || true
  sudo "$NIX_BIN-daemon" > /tmp/nix-daemon.log 2>&1 &
  sleep 2
fi

# 5. Export Path
export PATH="$(dirname "$NIX_BIN"):$PATH"
nix --version
