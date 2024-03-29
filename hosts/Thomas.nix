{ pkgs, config, suites, ... }:
{
  system.stateVersion = "21.11";

  ########
  # Boot #
  ########

  boot.initrd.availableKernelModules = [ "nvme" "ehci_pci" "xhci_pci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];

  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
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

  # Audio
  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
    support32Bit = true;
  };

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

  #hardware.bluetooth.enable = true;
  #services.blueman.enable = true;

  hardware.trackpoint.speed = 15;
  hardware.trackpoint.sensitivity = 15;

  ############
  # Services #
  ############

  nix.settings.cores = 8; # don't use up all my cores

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

  # USB mounting
  services.udisks2.enable = true;

  networking.networkmanager.enable = true;

  #################
  # System config #
  #################

  imports = suites.laptop; # this is from the global suite!

  ###############
  # User config #
  ###############

  programs.dconf.enable = true;

  home-manager.users.syp = { suites, ... }: {
    imports = suites.workstation;

    xinit.windowManager.awesome = {
      taskbars = ./../local/profiles/wm/awesome/Thomas-taskbars.lua;
      theme = ./../local/profiles/wm/awesome/Thomas-theme;
      wallpaper = ./../local/profiles/wm/awesome/Thomas-wallpaper.png;
    };

    xinit.initExtra = ''
      xinput set-prop "TPPS/2 ALPS TrackPoint" "libinput Accel Speed" -0.1
    '';

    home.packages = with pkgs; [
      acpilight # To make adj. brightness w/ hotkey work
    ];

    #services.blueman-applet-xinit.enable = true;
  };

  ################
  # Legacy stuff #
  ################

  environment.systemPackages = with pkgs; [
    # Email
    mutt
    getmail6
    msmtp
    procmail
    gnupg
    w3m
  ];
}
