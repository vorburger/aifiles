#!/usr/bin/env bash
set -euo pipefail

# This script is used as a postCreateCommand in .devcontainer/devcontainer.json
# to bootstrap the development environment.

# 1. Install Nix if it's not already available
if ! command -v nix >/dev/null 2>&1; then
    echo "Nix not found. Running installation script..."
    /workspaces/aifiles/skills/install-nix/scripts/install-nix.sh
fi

# 2. Source Nix profile (in case it's not in the PATH yet)
if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

# 3. Verify Flakes activation
nix flake --version || echo "Warning: 'nix flake' command failed. Please check Nix configuration."
