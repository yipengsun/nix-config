#!/usr/bin/env bash

set -euo pipefail

if (($# != 1)); then
    printf 'Usage: %s <hostname>\n' "$0" >&2
    exit 1
fi

hostname=$1
if [[ ! $hostname =~ ^[A-Za-z0-9][A-Za-z0-9-]*$ ]]; then
    printf 'Invalid hostname: %s\n' "$hostname" >&2
    exit 1
fi

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
repo_root=$(dirname -- "$script_dir")
output_dir="$repo_root/gen/$hostname"

if [[ -e $output_dir ]]; then
    printf 'Output already exists: %s\n' "$output_dir" >&2
    exit 1
fi

printf 'The output directory will be: %s\n' "$output_dir"
read -r -p "Do you want to proceed? (y/n): " answer
if [[ ! $answer =~ ^[Yy]$ ]]; then
    printf 'Exiting...\n'
    exit 0
fi

umask 077
temporary_dir=$(mktemp -d "$repo_root/gen/.${hostname}.XXXXXX")
cleanup() {
    if [[ -n $temporary_dir ]]; then
        rm -rf -- "$temporary_dir"
    fi
}
trap cleanup EXIT

ssh_dir="$temporary_dir/etc/ssh"
mkdir -p -- "$ssh_dir"

ssh-keygen -q -N "" -t rsa -b 4096 -f "$ssh_dir/ssh_host_rsa_key"
ssh-keygen -q -N "" -t ecdsa -f "$ssh_dir/ssh_host_ecdsa_key"
ssh-keygen -q -N "" -t ed25519 -f "$ssh_dir/ssh_host_ed25519_key"

chmod 600 "$ssh_dir"/ssh_host_*_key
chmod 644 "$ssh_dir"/ssh_host_*_key.pub

mv -- "$temporary_dir" "$output_dir"
temporary_dir=

printf 'Generated host keys in %s\n' "$output_dir"
printf 'ED25519 public key: %s\n' "$(<"$output_dir/etc/ssh/ssh_host_ed25519_key.pub")"
