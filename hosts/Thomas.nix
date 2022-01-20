{ pkgs, config, suites, ... }:
{
  system.stateVersion = "21.11";

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

  # Proxy
  services.v2ray.enable = false;
  services.v2ray.configFile = "/etc/nixos/config/v2ray/ByWave.json";
  #networking.proxy.default = "http://127.0.0.1:2080";

  networking.networkmanager.enable = true;

  ###############
  # User config #
  ###############

  imports = suites.laptop;

  home-manager.users.syp = {
    xinit.initExtra = ''
      # TrackPoint settings
      tpset() { xinput set-prop "TPPS/2 ALPS TrackPoint" "$@"; }

      tpset "Evdev Wheel Emulation" 1
      tpset "Evdev Wheel Emulation Button" 2
      tpset "Evdev Wheel Emulation Axes" 6 7 4 5
      tpset "Evdev Wheel Emulation Timeout" 200
      tpset "Device Accel Profile" -1
      tpset "Device Accel Constant Deceleration" 0.5
    '';

    xinit.windowManager.awesome = {
      theme = ./../local/profiles/wm/awesome/Thomas-theme;
      wallpaper = ./../local/profiles/wm/awesome/Thomas-wallpaper.png;
    };

    home.packages = with pkgs; [
      acpilight # To make adj. brightness w/ hotkey work
    ];
  };

  ################
  # Legacy stuff #
  ################

  environment.systemPackages = with pkgs; [
    breeze-gtk # GTK theme for 2 & 3

    # Utilities
    ranger
    #proxychains
    weechat
    #geteltorito

    # Applications
    #mpd

    # Email
    mutt
    getmail
    msmtp
    procmail
    gnupg
    w3m
  ];
}
