let
  # set ssh public keys here for your system and user
  hostThomas = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPziJHazosCbvSaSRO6voEniAdQCx2Fb+BDpq9umiSCD";
  hostHenri = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEPmHuWIMKKPdqt7FY3mVh0n2skSPeg11zX0BP9OAbYp";
  hostMichael = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMDHqRhXZ+iCQp3az0kYv2tJBoeXd/FVnfxrKbdvBlne";

  userSyp = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1s0sy5xORVQZcM7Yg1UcxqxGOazY41kci43OV0aqX7owjrxJKhezeOU0uehcvr2uaJykF5wRphaMjiY5tmaVyh35RKZ7tu5B7bx0FOjgATrUFAcBgKqzVMeCSmvmSUNK02HYrP+SOWbdgYECkyF+7PVxZoUefPnpBfGiqunfBWD5YrJMJPToFRqRW7Lcl+/6wIZQOAvPq8lvhfG89r9SvdiEX8umpYJKRgIl9k5wOsimTFJ5wLfq39sjECIzGCcbVLkiPzkOPLWRRgamICbiN4f0HF8kqdDU0mD1WZ5wHM72P68WKpHhMn9l+NEsGYik0fkW+RvyQmnXrpCkMXg3d";

  allKeys = [ hostThomas hostHenri hostMichael userSyp ];
in
{
  "passwd_root.age".publicKeys = allKeys;
  "passwd_syp.age".publicKeys = allKeys;

  "v2ray_tproxy.age".publicKeys = allKeys;

  "weather_api_key.age".publicKeys = [ userSyp ];
  "netrc_syp.age".publicKeys = [ userSyp ];
  "nix_conf_syp.age".publicKeys = [ userSyp ];
}
