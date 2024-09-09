{ pkgs, inputs, config, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
      ./graphics.nix
      ./tools
      ./virtualization.nix
    ];

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-gtk
    ];
  };


  services.logind.extraConfig = ''
    HandlePowerKey=hibernate
    HandleLidSwitch=hibernate
  '';
  #  environment.gnome.excludePackages = (with pkgs; [
  #    gnome-photos
  #    gnome-tour
  #  ]) ++ (with pkgs.gnome; [
  #    cheese # webcam tool
  #    gnome-music
  #    gnome-terminal
  #    # epiphany # web browser
  #    geary # email reader
  #    evince # document viewer
  #    totem # video player
  #    tali # poker game
  #    iagno # go game
  #    hitori # suoku game
  #    atomix # puzzle game
  #  ]);

  services.power-profiles-daemon.enable = false;
  services.thermald.enable = true;
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "performance";

      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 20;

      #Optional helps save long term battery health
      START_CHARGE_THRESH_BAT0 = 1; # 40 and bellow it starts to charge
      STOP_CHARGE_THRESH_BAT0 = 1; # 80 and above it stops charging
    };
  };

  # services.backups = {
  #   enable = true;
  #   repos.pictures = {
  #     paths = [ "${config.users.users.ormoyo.home}/Pictures" ];
  #     exclude = [ "Screenshots" ];
  #     time = "1month";
  #   };
  # };

  hardware.bluetooth.enable = true;
  services.xserver.libinput.enable = true;



  environment.localBinInPath = true;
  environment.pathsToLink = [ "/share/xdg-desktop-portal" "/share/applications" "/share/zsh" ];

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    backupFileExtension = "backup";

    useUserPackages = true;
    useGlobalPkgs = true;

    users = {
      ormoyo = import ./home/home.nix;
    };
  };

  services.udev.packages = [ pkgs.yubikey-personalization ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
  };

  security.pam.u2f.authFile = "/etc/u2f_keys";
  security.pam.services = {
    login.u2fAuth = true;
    sudo.u2fAuth = true;
  };

  networking.nftables.enable = false;

  nix.settings = {
    substituters = [ "https://nix-gaming.cachix.org" ];
    trusted-public-keys = [ "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4=" ];
  };

  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };

  system.stateVersion = "23.11";
}
