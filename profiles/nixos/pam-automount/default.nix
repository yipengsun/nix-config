{ pkgs, ... }:
let
  user = "syp";

  encryptedDir = "/home/%(USER)/sync/dropbox/data";
  mountDir = "/home/%(USER)/data";

  #cryptor = pkgs.encfs;
  cryptor = pkgs.gocryptfs;

  #fuseProgram = "encfs";
  fuseProgram = "gocryptfs";
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
  #security.pam.mount.additionalSearchPaths = [ cryptor ];
  security.pam.mount.fuseMountOptions = [
    "nodev"
    "nosuid"
    "quiet"
  ];

  security.pam.mount.extraVolumes = [
    # FIXME: this is a workaround for gocryptfs! see
    #   https://github.com/NixOS/nixpkgs/issues/201368
    # for more details
    ''<path>${pkgs.util-linux}/bin:/run/wrappers/bin:${cryptor}/bin</path>''

    # the actual volume
    ''<volume user="${user}" fstype="fuse" path="${fuseProgram}#${encryptedDir}" mountpoint="${mountDir}" />''
  ];
}
