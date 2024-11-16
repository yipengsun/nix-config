{
  disko.devices = {
    disk = {
      x = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "500M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "nixos";
              };
            };
          };
        };
      };
    };
    zpool = {
      nixos = {
        type = "zpool";
        rootFsOptions = {
          encryption = "aes-256-gcm";
          keyformat = "passphrase";
          keylocation = "file:///tmp/secret.key";
          compression = "zstd";
          "com.sun:auto-snapshot" = "false";
        };

        datasets = {
          "data/home" = {
            type = "zfs_fs";
            mountpoint = "/home";
            options."com.sun:auto-snapshot" = "true";
          };

          "local/root" = {
            type = "zfs_fs";
            mountpoint = "/";
          };
          "local/nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
          };
        };
      };
    };
  };
}
