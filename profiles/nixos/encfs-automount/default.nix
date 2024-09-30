{ pkgs, ... }:
let
  user = "syp";
  encryptedDir = "/home/%(USER)/tmp/encfs_test";
  mountDir = "/home/%(USER)/data";
  cryptor = pkgs.encfs;
in
{
  environment.systemPackages = [ cryptor ];
  # init a new encfs folder with:
  #   encfs <encrypted_foler> <decrypted_mount_point>

  # automount via pam_mount on login
  security.pam.mount.enable = true;
  security.pam.mount.additionalSearchPaths = [ cryptor ];
  security.pam.mount.extraVolumes = [
    ''<volume user="${user}" fstype="fuse" path="encfs#${encryptedDir}" mountpoint="${mountDir}" options="nodev,nosuid" />''
  ];
}
