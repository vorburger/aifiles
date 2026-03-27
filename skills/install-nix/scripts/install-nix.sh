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
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

# Set NIX_BIN for use in starting the daemon if needed
NIX_BIN=\$(command -v nix || echo "/nix/var/nix/profiles/default/bin/nix")

if [ ! -x "\$NIX_BIN" ]; then
  echo "Error: nix binary not found or not executable at \$NIX_BIN." >&2
  false
fi

# 3. Configure Nix
# Minimal configuration for environments where seccomp/sandboxing is restricted.
# We leverage the '!include nix.custom.conf' already in the default Determinate nix.conf.
sudo mkdir -p /etc/nix
cat << 'CONF' | sudo tee /etc/nix/nix.custom.conf > /dev/null
sandbox = false
filter-syscalls = false
CONF

if ! grep -q "experimental-features" /etc/nix/nix.conf 2>/dev/null; then
  echo "extra-experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf > /dev/null
fi

# 4. Start Daemon
if [ ! -e /nix/var/nix/daemon-socket/socket ]; then
  sudo pkill nix-daemon || true
  sudo "\$NIX_BIN-daemon" > /tmp/nix-daemon.log 2>&1 &
  sleep 2
fi

# 5. Export Path
export PATH="\$(dirname "\$NIX_BIN"):\$PATH"

# 6. Verify the installation
nix --version
nix flake --help > /dev/null
echo "Nix installation and configuration complete."
