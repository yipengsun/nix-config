# nix-config
My NixOS/nix-darwin/home-manager config based on devos


## Switch system config

In the project root:

```
sudo nixos-rebuild switch --flake ".#<hostname>"
```


## Tricks

### zfs auto-snapshot

Enable/disable auto-snapshot with the following command:

```
# zfs set com.sun:auto-snapshot=true <pool>/<fs>
```
