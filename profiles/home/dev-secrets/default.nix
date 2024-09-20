{ config, ... }: rec {
  age.secrets.netrc_syp.file = ../../../secrets/netrc_syp.age;
  home.file.".netrc" = {
    source = age.secrets.netrc_syp.path;
    onChange = "chmod 600 ~/.netrc";
  };
}
