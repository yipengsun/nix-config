{ pkgs, ... }:
let
  user = "syp";
  encryptedDir = "/home/%(USER)/sync/dropbox/data";
  mountDir = "/home/%(USER)/data";
  cryptor = pkgs.gocryptfs;
in
{
  environment.systemPackages = [ cryptor ];

  # automount via pam_mount on login
  security.pam.mount.enable = true;
  security.pam.mount.additionalSearchPaths = [ cryptor ];
  security.pam.mount.extraVolumes = [
    ''<volume user="${user}" fstype="fuse" path="gocryptfs#${encryptedDir}" mountpoint="${mountDir}" options="nodev,nosuid,quiet" />''
  ];
}
