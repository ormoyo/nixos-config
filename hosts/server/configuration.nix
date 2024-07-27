# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./syncthing.nix
      ./containers
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [ "hid_generic" "hid_cherry" ];  

  networking.hostName = "server"; # Define your hostname.
  networking.domain = "amoyal.org";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.interfaces.enp1s0.wakeOnLan.enable = true;
  environment.etc."zshsfas".source = "${pkgs.openssl}";

  # Set your time zone.
  time.timeZone = "Asia/Jerusalem";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IL";
    LC_IDENTIFICATION = "en_IL";
    LC_MEASUREMENT = "en_IL";
    LC_MONETARY = "en_IL";
    LC_NAME = "en_IL";
    LC_NUMERIC = "en_IL";
    LC_PAPER = "en_IL";
    LC_TELEPHONE = "en_IL";
    LC_TIME = "en_IL";
  };

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ormoyo = {
    isNormalUser = true;
    description = "Ormoyo";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.allow-unsafe-native-code-during-evaluation = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
     vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
     nmap
     ethtool
     htop
     compsize
     jdk8_headless
     openssl
     hdparm
  #  wget
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  networking.firewall.allowedTCPPorts = [ 443 81 ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
  powerManagement.powerUpCommands = 
  ''
    ${pkgs.hdparm}/sbin/hdparm -B 128 -S 180 /dev/disk/by-uuid/f597bcf2-0d98-456f-9890-4b39f1069c2d
  ''; 
#  systemd.services.hd-idle = {
#    enable = true;
#    wantedBy = ["multi-user.target"];

#    serviceConfig = {
#      ExecStart = "${pkgs.hd-idle}/bin/hd-idle -i 0 -c ata -a /dev/disk/by-uuid/f597bcf2-0d98-456f-9890-4b39f1069c2d -i 900";
#    };
#  };
}
