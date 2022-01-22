{ self, pkgs, ... }:
{
  age.secrets.passwd_syp.file = "${self}/secrets/passwd_syp.age";

  users.users.syp = {
    passwordFile = "/run/agenix/passwd_syp";
    description = "Yipeng Sun";
    shell = pkgs.zsh;
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "docker" "adbusers" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1s0sy5xORVQZcM7Yg1UcxqxGOazY41kci43OV0aqX7owjrxJKhezeOU0uehcvr2uaJykF5wRphaMjiY5tmaVyh35RKZ7tu5B7bx0FOjgATrUFAcBgKqzVMeCSmvmSUNK02HYrP+SOWbdgYECkyF+7PVxZoUefPnpBfGiqunfBWD5YrJMJPToFRqRW7Lcl+/6wIZQOAvPq8lvhfG89r9SvdiEX8umpYJKRgIl9k5wOsimTFJ5wLfq39sjECIzGCcbVLkiPzkOPLWRRgamICbiN4f0HF8kqdDU0mD1WZ5wHM72P68WKpHhMn9l+NEsGYik0fkW+RvyQmnXrpCkMXg3d"
    ];
  };

  # for decrypting files on user login
  home-manager.users.syp.homeage.identityPaths = [ "~/.ssh/id_rsa" ];
}
