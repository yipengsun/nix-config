{ pkgs, ... }:
let
  user = "syp";
  encryptedDir = "/home/%(USER)/sync/dropbox/data";
  mountDir = "/home/%(USER)/data";
  cryptor = pkgs.encfs;
in
{
  environment.systemPackages = [ cryptor ];

  # automount via pam_mount on login
  security.pam.mount.enable = false;
  security.pam.mount.additionalSearchPaths = [ cryptor ];
  security.pam.mount.extraVolumes = [
    ''<volume user="${user}" fstype="fuse" path="encfs#${encryptedDir}" mountpoint="${mountDir}" options="nonempty" />''
  ];
}
