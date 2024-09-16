{
  virtualisation.docker = {
    enable = true;
    storageDriver = "overlay2";
  };
  systemd.services.docker.after = [ "var-lib-docker.mount" ];
}
