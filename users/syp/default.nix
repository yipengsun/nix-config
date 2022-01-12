{ self, ... }:
{
  #home-manager.users = { inherit (hmUsers) nixos; };

  age.secrets.sypPasswd.file = "${self}/secrets/passwd_syp.age";
  users.users.syp = {
    passwordFile = "/run/agenix/sypPasswd.age";
    description = "Yipeng Sun";
    isNormalUser = true;
    extraGroups = [ "wheels" ];
  };
}
