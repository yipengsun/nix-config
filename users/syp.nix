{
  self,
  pkgs,
  lib,
  ...
}:
let
  configSypCommon = {
    description = "Yipeng Sun";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1s0sy5xORVQZcM7Yg1UcxqxGOazY41kci43OV0aqX7owjrxJKhezeOU0uehcvr2uaJykF5wRphaMjiY5tmaVyh35RKZ7tu5B7bx0FOjgATrUFAcBgKqzVMeCSmvmSUNK02HYrP+SOWbdgYECkyF+7PVxZoUefPnpBfGiqunfBWD5YrJMJPToFRqRW7Lcl+/6wIZQOAvPq8lvhfG89r9SvdiEX8umpYJKRgIl9k5wOsimTFJ5wLfq39sjECIzGCcbVLkiPzkOPLWRRgamICbiN4f0HF8kqdDU0mD1WZ5wHM72P68WKpHhMn9l+NEsGYik0fkW+RvyQmnXrpCkMXg3d"
    ];
    shell = pkgs.fish;
  };

  isLinux = pkgs.stdenv.isLinux;
  isDarwin = pkgs.stdenv.isDarwin;
in
{
  age.secrets = lib.mkIf isLinux ({
    passwd_syp.file = "${self}/secrets/passwd_syp.age";
  });

  users.users.syp =
    configSypCommon
    // (
      if isLinux then
        {
          hashedPasswordFile = "/run/agenix/passwd_syp";
          isNormalUser = true;
          extraGroups = [
            "wheel"
            "networkmanager"
            "video"
            "audio"
            "docker"
            "adbusers"
          ];
          uid = 1000;
        }
      else
        {
          name = "syp";
        }
    );

  home-manager.users.syp =
    { config, ... }:
    {
      home.homeDirectory = lib.mkIf isDarwin (lib.mkForce "/Users/syp");

      # for decrypting files on user login
      age.identityPaths = [
        "${config.home.homeDirectory}/.ssh/id_rsa"
      ];
    };
}
