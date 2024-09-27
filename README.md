# nix-config

My NixOS/nix-darwin config.


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


## Acknowledgement

- This project was originally based on [`digga`](https://github.com/divnix/digga).
- `digga` is no longer actively maintained.
  To learn `nix` and make things simpler,
  I studied [`lite-config`](https://github.com/yelite/lite-config) flake,
  stole the bits useful to me,
  and remade the project into its current state.
