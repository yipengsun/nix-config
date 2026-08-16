{
  self,
  lib,
  pkgs,
  config,
  ...
}:
let
  sypSshPublicKey = import ../data/syp-ssh-public-key.nix;
in
{
  options.nix-config.bootstrap.emptyRootPassword = lib.mkEnableOption "an empty root password for bootstrapping";

  config = lib.mkMerge [
    {
      # main config
      users.users.root.shell = pkgs.fish;
      users.users.root.openssh.authorizedKeys.keys = [ sypSshPublicKey ];

      home-manager.users.root = {
        imports = self.suites.home.base;
      };
    }
    (lib.mkIf config.nix-config.bootstrap.emptyRootPassword {
      users.users.root.password = "";
    })
    (lib.mkIf (!config.nix-config.bootstrap.emptyRootPassword) {
      age.secrets.password_root.file = "${self}/secrets/passwd_root.age";
      users.users.root.hashedPasswordFile = config.age.secrets.password_root.path;
    })
  ];
}
