{ pkgs, ... }:
let
  user = "syp";

  encryptedDir = "/home/%(USER)/sync/dropbox/data";
  mountDir = "/home/%(USER)/data";

  cryptor = pkgs.encfs;
  #cryptor = pkgs.gocryptfs;  # FIXME: gocryptfs doesn't mount with pam_mount

  fuseProgram = "encfs";
  #fuseProgram = "gocryptfs";
in
{
  environment.systemPackages = [ cryptor ];
  # init a new encfs folder with:
  #   encfs <encrypted_foler> <decrypted_mount_point>
  #
  # init a new gocryptfs encrypted folder with:
  #   gocryptfs -init <path_to_encrypted_folder>

  # automount via pam_mount on login
  security.pam.mount.enable = true;
  security.pam.mount.additionalSearchPaths = [ cryptor ];
  security.pam.mount.extraVolumes = [
    ''<volume user="${user}" fstype="fuse" path="${fuseProgram}#${encryptedDir}" mountpoint="${mountDir}" options="nodev,nosuid,quiet" />''
  ];
}
