{ pkgs, ... }:
let
  user = "syp";
  encryptedDir = "/home/syp/sync/dropbox/data";
  mountDir = "~/data";
in
{
  # set up pam mount
  security.pam.mount.additionalSearchPaths = [ pkgs.encfs ];
  security.pam.mount.extraVolumes = [
    # for me only, don't do this for root!
    ''<volume user="${user}" fstype="fuse" path="encfs#${encryptedDir}" mountpoint="${mountDir}" options="nonempty" />''
  ];

  # automount via pam_mount on login
  security.pam.services.login.pamMount = true;
}
