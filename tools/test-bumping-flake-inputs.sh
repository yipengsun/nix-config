#!/usr/bin/env bash

nix flake update \
    --override-input nixpkgs "github:nixos/nixpkgs/nixos-unstable"

for h in Henri Thomas; do
    nix build \
        ".#nixosConfigurations.$h.config.system.build.toplevel" \
        --override-input nixpkgs "github:nixos/nixpkgs/nixos-unstable"
done
