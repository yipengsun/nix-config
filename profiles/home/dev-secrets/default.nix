{ config, ... }:
{
  age.secrets = {
    netrc = {
      file = ../../../secrets/netrc_syp.age;
      path = "${config.home.homeDirectory}/.netrc";
      mode = "600";
    };

    nix_conf = {
      file = ../../../secrets/nix_conf_syp.age;
      path = "${config.home.homeDirectory}/.config/nix/nix.conf";
      mode = "600";
    };
  };
}
