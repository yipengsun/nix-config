#!/usr/bin/env bash

set -euo pipefail

printf 'Updating nixpkgs-pointer...\n\n'
nix flake update nixpkgs-pointer

printf '\nEvaluating all systems...\n\n'
nix flake check --all-systems --no-build

hosts=$(nix eval --raw .#nixosConfigurations --apply '
    configs: builtins.concatStringsSep "\n" (builtins.attrNames configs)
')

while IFS= read -r host; do
    [[ -n $host ]] || continue

    printf '\n########\nBuilding %s...\n########\n\n' "$host"
    nix build ".#nixosConfigurations.$host.config.system.build.toplevel" \
        --no-link \
        --print-build-logs
    printf '\n%s built successfully.\n' "$host"
done <<< "$hosts"
