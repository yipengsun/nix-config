{ config, ... }: {
  age.secrets.netrc = {
    file = ../../../secrets/netrc_syp.age;
    path = "${config.home.homeDirectory}/.netrc";
    mode = "600";
  };
}
