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
  sudo /nix/var/nix/profiles/default/bin/nix-daemon > /tmp/nix-daemon.log 2>&1 &
  sleep 2
fi

# 4. Configure Fish shell for Nix (if fish is installed)
if command -v fish >/dev/null 2>&1; then
  mkdir -p ~/.config/fish/conf.d
  cat << 'EOF' > ~/.config/fish/conf.d/nix.fish
if test -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
end
EOF
fi

# 5. Enable Flakes and the new Nix command
mkdir -p ~/.config/nix
if ! grep -q "experimental-features" ~/.config/nix/nix.conf 2>/dev/null; then
  echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
fi

# 6. Verify the installation
nix --version
nix flake --help
