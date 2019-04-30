# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
  

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable = true;
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];

  boot.initrd.luks.devices = [
    {
      name = "nixos-main";
      device = "/dev/disk/by-uuid/XXXXX";
      preLVM = true;
      allowDiscards = true;
    }
  ];

  # Select internationalisation properties.
  i18n = {
    consoleKeyMap = "us";
    defaultLocale = "zh_TW.UTF-8";
    inputMethod = {
      enabled = "fcitx";
      fcitx.engines = with pkgs.fcitx-engines; [ chewing ];
    };
  };
  fonts.fonts = with pkgs; [
    source-code-pro
    source-sans-pro
    source-serif-pro
    inconsolata
    noto-fonts
    noto-fonts-cjk
    # issue: huge emoji in terminals
    # noto-fonts-emoji
    liberation_ttf
  ];

  # Set your time zone.
  time.timeZone = "Asia/Taipei";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
     wget emacs vim git firefox trayer lilyterm
     xscreensaver dispad xorg.xev xss-lock gnome3.networkmanagerapplet gnome3.gnome_keyring
     haskellPackages.xmobar gnome3.dconf
     # utils
     file evince dmenu
     # pulseaudio
     pasystray paprefs pavucontrol
     # application launcher
     valauncher
     # debugger
     gdb
     # power
     upower acpi
     # screenshot
     shutter
     # file manager
     gnome3.nautilus
     # icon theme
     hicolor-icon-theme
     ### IM
     skypeforlinux
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable syslogd
  services.syslogd.enable = true;

  # Enable touchpad support.
  services.xserver.libinput = {
    enable = true;
    disableWhileTyping = true;
    accelSpeed = "1";
    additionalOptions = ''
      Option "TappingDrag" "false"
    '';
  };    
  #services.xserver.multitouch = {
  #  enable = true;
  #  invertScroll = true;
  #  ignorePalm = true;
  #};

  services.xserver.windowManager.xmonad = {
    enable = true;
    enableContribAndExtras = true;
  };
  services.xserver.windowManager.default = "xmonad";

  # Enable the KDE Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.guest = {
  #   isNormalUser = true;
  #   uid = 1000;
  # };
  users.users.pancake = {
    isNormalUser = true;
    home = "/home/pancake";
    extraGroups = [ "audio" ];
  };
  users.groups.xmonad.members = [ "pancake"  "root" ];
  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.09"; # Did you read the comment?
  

  systemd.services.xmonadBrightness = {
    wantedBy = [ "multi-user.target" ];
    before = [ "nodered.service" ];
    description = "Allow xmonad-extra to change brightness";
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      ExecStart = ''/run/current-system/sw/bin/bash -c "chgrp -R -H xmonad /sys/class/backlight/intel_backlight && chmod g+w /sys/class/backlight/intel_backlight/brightness"'';
    };
  };

  services.logind.lidSwitch = "suspend";
  services.logind.extraConfig = ''
    HoldoffTimeoutSec=0s
  '';
  swapDevices = [ { device = "/var/swap"; size = 4096; } ];
  boot.kernelParams = [ "acpi_backlight=vendor" ];
  nixpkgs.config.allowUnfree = true;
}
