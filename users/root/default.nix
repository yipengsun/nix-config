{ self, lib, config, ... }:
lib.mkMerge [{
  # main config
  openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1s0sy5xORVQZcM7Yg1UcxqxGOazY41kci43OV0aqX7owjrxJKhezeOU0uehcvr2uaJykF5wRphaMjiY5tmaVyh35RKZ7tu5B7bx0FOjgATrUFAcBgKqzVMeCSmvmSUNK02HYrP+SOWbdgYECkyF+7PVxZoUefPnpBfGiqunfBWD5YrJMJPToFRqRW7Lcl+/6wIZQOAvPq8lvhfG89r9SvdiEX8umpYJKRgIl9k5wOsimTFJ5wLfq39sjECIzGCcbVLkiPzkOPLWRRgamICbiN4f0HF8kqdDU0mD1WZ5wHM72P68WKpHhMn9l+NEsGYik0fkW+RvyQmnXrpCkMXg3d"
  ];
}
  (lib.mkIf (config.networking.hostName == "NixOS") {
    users.users.root.password = ""; # for the live ISO only
  })
  (lib.mkIf (config.networking.hostName != "NixOS") {
    age.secrets.rootPasswd.file = "${self}/secrets/passwd_root.age";
    users.users.root.passwordFile = "/run/agenix/rootPasswd.age";
  })]
