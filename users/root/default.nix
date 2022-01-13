{ self, lib, pkgs, config, ... }:
let
  testHosts = [ "NixOS" "Thomas" ]; # these hosts get 'root' w/ an empty password
in
lib.mkMerge [{
  # main config
  users.users.root.shell = pkgs.zsh;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1s0sy5xORVQZcM7Yg1UcxqxGOazY41kci43OV0aqX7owjrxJKhezeOU0uehcvr2uaJykF5wRphaMjiY5tmaVyh35RKZ7tu5B7bx0FOjgATrUFAcBgKqzVMeCSmvmSUNK02HYrP+SOWbdgYECkyF+7PVxZoUefPnpBfGiqunfBWD5YrJMJPToFRqRW7Lcl+/6wIZQOAvPq8lvhfG89r9SvdiEX8umpYJKRgIl9k5wOsimTFJ5wLfq39sjECIzGCcbVLkiPzkOPLWRRgamICbiN4f0HF8kqdDU0mD1WZ5wHM72P68WKpHhMn9l+NEsGYik0fkW+RvyQmnXrpCkMXg3d"
  ];

  home-manager.users.root = { suites, ... }: {
    imports = suites.base;
  };
}
  (lib.mkIf (builtins.elem config.networking.hostName testHosts) {
    users.users.root.password = ""; # for the live ISO only
  })
  (lib.mkIf (!builtins.elem config.networking.hostName testHosts) {
    age.secrets.rootPasswd.file = "${self}/secrets/passwd_root.age";
    users.users.root.passwordFile = "/run/agenix/rootPasswd.age";
  })]
