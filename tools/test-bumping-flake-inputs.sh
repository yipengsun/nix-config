#!/usr/bin/env bash

set -euo pipefail

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

input_overrides=(
    --override-input nixpkgs github:NixOS/nixpkgs/master
    --override-input nix-darwin github:nix-darwin/nix-darwin/master
    --override-input home-manager github:nix-community/home-manager/master
)

# Resolve master once so every command tests the same revisions, without
# changing the repository's pins.
printf 'Resolving latest nixpkgs, nix-darwin, and Home Manager master...\n\n'
input_metadata=$(nix flake metadata --refresh --json "${input_overrides[@]}")

# Include the exact tested revisions in the CI log for a later pin update.
flake_args=(--no-write-lock-file)
for input in nixpkgs nix-darwin home-manager; do
    input_ref=$(jq -er --arg input "$input" '
        .locks as $lock
        | $lock.nodes[$lock.nodes[$lock.root].inputs[$input]].locked
        | "github:\(.owner)/\(.repo)/\(.rev)"
    ' <<< "$input_metadata")
    printf '%s: %s\n' "$input" "$input_ref"
    flake_args+=(--override-input "$input" "$input_ref")
done

printf '\nEvaluating %s...\n\n' "$current_system"
nix flake check "${flake_args[@]}" --print-build-logs

hosts=$(nix eval "${flake_args[@]}" --raw ".#$configurations" --apply '
    configs: builtins.concatStringsSep "\n" (builtins.attrNames configs)
')

while IFS= read -r host; do
    [[ -n $host ]] || continue

    printf '\n########\nBuilding %s...\n########\n\n' "$host"
    nix build "${flake_args[@]}" ".#$configurations.$host.$host_output" \
        --no-link \
        --print-build-logs
    printf '\n%s built successfully.\n' "$host"
done <<< "$hosts"
