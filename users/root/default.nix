{ self, lib, config, ... }:
lib.mkMerge [{
  # main config
}
  (lib.mkIf (config.networking.hostName == "NixOS") {
    users.users.root.password = ""; # for the live ISO only
  })
  (lib.mkIf (config.networking.hostName != "NixOS") {
    age.secrets.rootPasswd.file = "${self}/secrets/passwd_root.age";
    users.users.root.passwordFile = "/run/agenix/rootPasswd.age";
  })]
