{ config, ... }: {
  age.secrets.".netrc" = {
    file = ../../../secrets/netrc_syp.age;
    mode = "600";
  };
}
