{ config, self, pkgs, ... }:
{
  system.stateVersion = "24.11";


  ########
  # Boot #
  ########

  boot.initrd.availableKernelModules = [ "nvme" "ehci_pci" "xhci_pci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];

  boot.kernelModules = [ "kvm-amd" "acpi_call" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.requestEncryptionCredentials = true;

  # Use the systemd-boot EFI boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.consoleMode = "max";

  boot.loader.efi.canTouchEfiVariables = true;

  # Don't use NixOS stage-1
  # to workaround the following issue:
  #   https://github.com/NixOS/nixpkgs/issues/342082
  # see also:
  #   https://blog.decent.id/post/nixos-systemd-initrd/
  boot.initrd.systemd.enable = true;


  ##############
  # Filesystem #
  ##############

  swapDevices = [ ];

  # For zfs
  #   generate with `head -c4 /dev/urandom | od -A none -t x4`
  networking.hostId = "9a2d8f8d";


  ############
  # Hardware #
  ############

  hardware.enableRedistributableFirmware = true;

  hardware.graphics.enable = true;

  hardware.cpu.amd.updateMicrocode = true;

  # Custom network interface naming
  services.udev.extraRules = ''
    # Persistent network interface naming
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="08:bf:b8:3b:d2:c7", NAME="net0"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="60:e3:2b:fe:14:d3", NAME="wifi0"
  '';

  # Audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  #hardware.bluetooth.enable = true;
  #services.blueman.enable = true;


  ############
  # Services #
  ############

  nix.settings.cores = 12; # don't use up all my cores

  services.openssh.openFirewall = true;

  # X11
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];
  services.xserver.deviceSection = ''
    Option "TearFree" "true"
    Option "Backlight" "amdgpu_bl0"
  '';
  services.xserver.displayManager.startx.enable = true;

  # Display manager
  services.displayManager.ly.enable = true;

  # Update firmware
  services.fwupd.enable = true;

  # USB mounting
  services.udisks2.enable = true;

  networking.networkmanager.enable = true;


  #################
  # System config #
  #################

  imports = self.suites.nixos.workstation
    ++ [ self.profiles.nixos.v2ray-tproxy ]
    ++ (with self.users; [ root syp ])
    ++ [ ./disko-config.nix ];

  environment.systemPackages = with pkgs; [
    rocmPackages.rocm-smi
    rocmPackages.rocminfo
  ];


  ###############
  # User config #
  ###############

  programs.dconf.enable = true;

  home-manager.users.syp = { pkgs, ... }: {
    imports = self.suites.home.workstation
      ++ [
      self.profiles.home.wm-x11
    ];

    awesome-wm-config = {
      taskbars = ./awesome-wm/taskbars.lua;
      theme = ./awesome-wm/theme;
      wallpaper = ./awesome-wm/wallpaper.png;
    };

    # Configure dual screen setup
    xsession.profileExtra = ''
      LEFT='HDMI-A-0'
      RIGHT='DisplayPort-0'
      ${pkgs.xorg.xrandr}/bin/xrandr --output $LEFT --output $RIGHT --right-of $LEFT
    '';
  };
}
