let
  # set ssh public keys here for your system and user
  hostThomas = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPziJHazosCbvSaSRO6voEniAdQCx2Fb+BDpq9umiSCD";
  hostHenri = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEPmHuWIMKKPdqt7FY3mVh0n2skSPeg11zX0BP9OAbYp";
  hostMichael = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMDHqRhXZ+iCQp3az0kYv2tJBoeXd/FVnfxrKbdvBlne";

  userSyp = import ../data/syp-ssh-public-key.nix;

  allKeys = [
    hostThomas
    hostHenri
    hostMichael
    userSyp
  ];
in
{
  "passwd_root.age".publicKeys = allKeys;
  "passwd_syp.age".publicKeys = allKeys;

  "v2ray_tproxy.age".publicKeys = allKeys;

  "netrc_syp.age".publicKeys = [ userSyp ];
  "nix_conf_syp.age".publicKeys = [ userSyp ];
}
