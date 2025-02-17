#!/usr/bin/env bash

set -e  # exit on error

echo "Updating nixpkgs input..."
echo ""
nix flake update \
    --override-input nixpkgs "github:nixos/nixpkgs/nixos-unstable"

echo "Building hosts"
echo ""
for h in Henri Thomas; do
    echo ""
    echo "########"
    echo "Building $h..."
    echo "########"
    echo ""

    nix build \
        ".#nixosConfigurations.$h.config.system.build.toplevel" \
        --override-input nixpkgs "github:nixos/nixpkgs/nixos-unstable"

    echo ""
    echo "########"
    echo "$h built successfully."
    echo "########"
    echo ""
done
