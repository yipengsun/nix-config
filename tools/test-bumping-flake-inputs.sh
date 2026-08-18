#!/usr/bin/env bash

set -euo pipefail

printf 'Updating nixpkgs-pointer...\n\n'
nix flake update nixpkgs-pointer

current_system=$(nix eval --raw --impure --expr builtins.currentSystem)

case $current_system in
    x86_64-linux)
        configurations=nixosConfigurations
        host_output=config.system.build.toplevel
        ;;
    aarch64-darwin)
        configurations=darwinConfigurations
        host_output=system
        ;;
    *)
        printf 'Unsupported CI system: %s\n' "$current_system" >&2
        exit 1
        ;;
esac

printf '\nEvaluating %s...\n\n' "$current_system"
nix flake check --print-build-logs

hosts=$(nix eval --raw ".#$configurations" --apply '
    configs: builtins.concatStringsSep "\n" (builtins.attrNames configs)
')

while IFS= read -r host; do
    [[ -n $host ]] || continue

    printf '\n########\nBuilding %s...\n########\n\n' "$host"
    nix build ".#$configurations.$host.$host_output" \
        --no-link \
        --print-build-logs
    printf '\n%s built successfully.\n' "$host"
done <<< "$hosts"
