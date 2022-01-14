{
  programs.mpv = {
    enable = true;
    profiles = {
      gpu-hq = {
        alang = "cn,en";
        slang = "cn,en";
      };
    };
    defaultProfiles = [ "gpu-hq" ];
  };
}
