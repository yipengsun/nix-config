# nix-config
My NixOS/nix-darwin/home-manager config based on devos


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

### zfs auto-snapshot

Enable/disable auto-snapshot with the following command:

```
sudo zfs set com.sun:auto-snapshot=true <pool>/<fs>
```
