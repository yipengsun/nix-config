# nix-config

My NixOS/nix-darwin/home-manager config


## Switch system config

In the project root:

```
sudo nixos-rebuild switch --flake ".#<hostname>"
```


## Tricks

### Install `nix`

On non-NixOS, use the Determinate `nix` installer:

```
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

```
sudo zfs set com.sun:auto-snapshot=true <pool>/<fs>
```
