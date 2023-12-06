{ config, ... }: {
  homeage.file."netrc" = {
    source = ../../../secrets/netrc_syp.age;
    symlinks = [ "${config.home.homeDirectory}/.netrc" ];
    mode = "600";
  };
}
