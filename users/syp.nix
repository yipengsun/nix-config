{
  config,
  self,
  pkgs,
  lib,
  ...
}:
let
  sypSshPublicKey = import ../data/syp-ssh-public-key.nix;

  configSypCommon = {
    description = "Yipeng Sun";
    openssh.authorizedKeys.keys = [ sypSshPublicKey ];
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
          hashedPasswordFile = config.age.secrets.passwd_syp.path;
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
      home.homeDirectory = lib.mkIf isDarwin (lib.mkForce "/Users/${config.home.username}");

      # for decrypting files on user login
      age.identityPaths = [
        "${config.home.homeDirectory}/.ssh/id_rsa"
      ];
    };
}
