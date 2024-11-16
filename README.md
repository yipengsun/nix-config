# nix-config

My NixOS/nix-darwin config.


## Switch system config

In the project root:

```shell
sudo nixos-rebuild switch --flake ".#<hostname>"
```


## Install on a remote host

First, generate a set of SSH keys for the new host:

```shell
gen-host-ssh-keys.sh <hostname>
# output to gen/<hostname>
```

Then, rekey secrets so the new host can decrypt them:

```shell
cd secrets
# then add a pubkey from the new host to secrets.nix
agenix -r
```

Finally, use `nixos-anywhere` to build on current machine then configure the
new remote host:

```shell
nixos-anywhere --extra-files gen/<hostname> --flake .#<hostname> nixos@<host_ip> --no-substitute-on-destination
```


## Tricks

### Install `nix`

On non-NixOS, use the Determinate `nix` installer:

```shell
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```


### Debug flake

```shell
nix repl
# in the resulting nix prompt
> :lf .
```


### zfs auto-snapshot

Enable/disable auto-snapshot with the following command:

```shell
sudo zfs set com.sun:auto-snapshot=true <pool>/<fs>
```


## Configure `maestral`

```shell
maestral auth link  # follow instruction

mkdir -p ~/sync/dropbox
maestral config set path ~/sync/dropbox

# common excludes
maestral excluded add /audios
maestral excluded add /backup
maestral excluded add /git
maestral excluded add /researches/lhcb-hardware_related
maestral excluded add /videos
```


## Acknowledgement

- This project was originally based on [`digga`](https://github.com/divnix/digga).
- `digga` is no longer actively maintained.
  To learn `nix` and make things simpler,
  I studied [`lite-config`](https://github.com/yelite/lite-config) flake,
  stole the bits useful to me,
  and remade the project into its current state.
