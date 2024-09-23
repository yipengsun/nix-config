{ config, ... }: {
  age.secrets.netrc_syp.file = ../../../secrets/netrc_syp.age;
  home.file.".netrc" = {
    source = config.age.secrets.netrc_syp.path;
    onChange = "chmod 600 ~/.netrc";
  };
}
