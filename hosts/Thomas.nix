{ self, pkgs, config, suites, ... }:
{
  system.stateVersion = "20.09";

  ########
  # Boot #
  ########

  boot.initrd.availableKernelModules = [ "nvme" "ehci_pci" "xhci_pci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = [ "kvm-amd" "acpi_call" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];

  # Force use of the thinkpad_acpi driver for backlight control.
  # This allows the backlight save/load  systemd service to work.
  boot.kernelParams = [ "acpi_backlight=native" "iommu=soft" ];

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.requestEncryptionCredentials = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  ##############
  # Filesystem #
  ##############

  fileSystems."/" = {
    device = "nixos/local/root";
    fsType = "zfs";
  };

  fileSystems."/nix" = {
    device = "nixos/local/nix";
    fsType = "zfs";
  };

  fileSystems."/home" = {
    device = "nixos/data/home";
    fsType = "zfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/B4CC-6FF8";
    fsType = "vfat";
  };

  fileSystems."/var/lib/docker" = {
    device = "/dev/disk/by-uuid/0b41caa1-d45c-473a-a7ed-d6d5f577d439";
    fsType = "ext4";
  };

  swapDevices = [ ];

  # For zfs
  networking.hostId = "559e7746";

  #################
  # Drivers, etc. #
  #################

  hardware.enableRedistributableFirmware = true;

  # Hardware OpenGL acceleration
  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];

  # Enable CPU microcode update
  hardware.cpu.amd.updateMicrocode = true;

  # ACPI light instead of xbacklight
  hardware.acpilight.enable = true;

  # PulseAudio
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;

  # Custom network interface naming
  services.udev.extraRules = ''
    # Persistent network interface naming
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="00:2b:67:e7:a5:8a", NAME="net1"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="00:2b:67:e7:a5:89", NAME="net0"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="34:cf:f6:f5:69:be", NAME="wifi0"

    # Disable USB wakeup
    SUBSYSTEM=="pci", KERNEL=="0000:07:00.3", ATTR{power/wakeup}="disabled"
    SUBSYSTEM=="pci", KERNEL=="0000:07:00.4", ATTR{power/wakeup}="disabled"
  '';

  ############
  # Services #
  ############

  services.zfs.trim.enable = true; # Trim SSD periodically
  services.zfs.autoSnapshot = {
    enable = true;
    frequent = 3;
    monthly = 6;
  };

  # Enable docker daemon
  virtualisation.docker = {
    enable = true;
    storageDriver = "overlay2";
  };
  systemd.services.docker.after = [ "var-lib-docker.mount" ];

  services.logind.lidSwitch = "ignore";
  services.logind.lidSwitchExternalPower = "ignore";
  services.logind.lidSwitchDocked = "ignore";

  services.openssh.permitRootLogin = "no";

  # X11
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];
  services.xserver.deviceSection = ''
    Option "TearFree" "true"
    Option "Backlight" "amdgpu_bl0"
  '';
  services.xserver.displayManager.startx.enable = true;

  # Update firmware
  services.fwupd.enable = true;

  # v2ray
  services.v2ray.enable = false;
  services.v2ray.configFile = "/etc/nixos/config/v2ray/ByWave.json";
  #networking.proxy.default = "http://127.0.0.1:2080";

  # Dropbox
  #services.dropbox.enable = true;

  #################
  # Global config #
  #################

  # Network manager
  networking.networkmanager.enable = true;

  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Europe/Paris";

  # fcitx
  i18n.inputMethod = {
    enabled = "fcitx";
  };

  # encfs automount via pam_mount
  #security.pam.services.login.pamMount = true;
  #security.pam.mount.encfsFolderPairs = [
  #{ user = "syp"; src = "/home/syp/.sync/Dropbox/data"; dst = "/home/syp/data"; }
  #];

  ###############
  # User config #
  ###############

  age.secrets.passwd_syp.file = "${self}/secrets/passwd_syp.age";

  imports = suites.common;

  ################
  # Legacy stuff #
  ################

  environment.systemPackages = with pkgs; [
    # Editor
    neovim
    nodejs # a neovim dep for now
    #neovim-vimdiff

    # Window manager
    awesome
    i3lock
    breeze-gtk # GTK theme for 2 & 3
    acpilight # To make adj. brightness w/ hotkey work

    # Utilities
    ranger
    #proxychains
    weechat
    #geteltorito

    # Applications
    zathura
    #mpv
    #mpd

    # Email
    mutt
    getmail
    msmtp
    procmail
    gnupg
    w3m
    extract_url
  ];
}
