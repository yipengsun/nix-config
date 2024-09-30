{ pkgs, ... }:
let
  user = "syp";
  encryptedDir = "/home/%(USER)/sync/dropbox/data";
  mountDir = "/home/%(USER)/data";
  cryptor = pkgs.gocryptfs;
in
{
  environment.systemPackages = [ cryptor ];
  # init a new gocryptfs encrypted folder with:
  #   gocryptfs -init <path_to_encrypted_folder>

  # automount via pam_mount on login
  security.pam.mount.enable = true; # FIXME: doesn't decrypt correctly on login
  security.pam.mount.additionalSearchPaths = [ cryptor ];
  security.pam.mount.extraVolumes = [
    ''<volume user="${user}" fstype="fuse" path="gocryptfs#${encryptedDir}" mountpoint="${mountDir}" options="nodev,nosuid,quiet,nonempty,allow_other" />''
  ];

  # make 'allow_other' available to non-root users, doesn't work!
  #programs.fuse.userAllowOther = true;
}
