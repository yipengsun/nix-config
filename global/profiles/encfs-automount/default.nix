{ pkgs, ... }:
{
  # set up pam mount
  security.pam.mount.additionalSearchPaths = [ pkgs.encfs ];
  security.pam.mount.extraVolumes = [
    # for me only, don't do this for root!
    ''<volume fstype="fuse" path="encfs#/home/syp/.sync/Dropbox/data" mountpoint="~/data" options="nonempty" />''
  ];

  # automount via pam_mount on login
  security.pam.services.login.pamMount = true;
}
