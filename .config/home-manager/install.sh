#!/bin/sh
set -e

echo "🚀 Starting Setup (NixOS 25.11)..."

if nix-channel --list | grep -q "home-manager"; then
	nix-channel --remove home-manager
fi

nix-channel --add https://github.com/nix-community/home-manager/archive/release-25.11.tar.gz home-manager
nix-channel --update

echo "📦 Installing Home Manager..."
nix-shell '<home-manager>' -A install

echo "✨ Applying configuration..."
home-manager switch

echo "🎉 Done! User is configured."
