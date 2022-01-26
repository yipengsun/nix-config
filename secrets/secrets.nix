let
  # set ssh public keys here for your system and user
  hostThomas = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPziJHazosCbvSaSRO6voEniAdQCx2Fb+BDpq9umiSCD";
  userSyp = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1s0sy5xORVQZcM7Yg1UcxqxGOazY41kci43OV0aqX7owjrxJKhezeOU0uehcvr2uaJykF5wRphaMjiY5tmaVyh35RKZ7tu5B7bx0FOjgATrUFAcBgKqzVMeCSmvmSUNK02HYrP+SOWbdgYECkyF+7PVxZoUefPnpBfGiqunfBWD5YrJMJPToFRqRW7Lcl+/6wIZQOAvPq8lvhfG89r9SvdiEX8umpYJKRgIl9k5wOsimTFJ5wLfq39sjECIzGCcbVLkiPzkOPLWRRgamICbiN4f0HF8kqdDU0mD1WZ5wHM72P68WKpHhMn9l+NEsGYik0fkW+RvyQmnXrpCkMXg3d";
  allKeys = [ hostThomas userSyp ];
in
{
  "passwd_root.age".publicKeys = allKeys;
  "passwd_syp.age".publicKeys = allKeys;

  "weather_api_key.age".publicKeys = [ userSyp ];
  "netrc_syp.age".publicKeys = [ userSyp ];
}
