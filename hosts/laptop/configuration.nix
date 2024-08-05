{ pkgs, inputs, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
      ./graphics.nix
      ./tools
      ./virtualization.nix
    ];

  networking.hostName = "whipi";
  networking.domain = "pc.org";

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-gtk
    ];
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;

    xwayland.enable = true;
  };

  services.displayManager.sessionPackages = (with pkgs; [ hyprland ]);

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.gdm.enableGnomeKeyring = true;
  services.xserver = {
    # Enable the X11 windowing system.
    enable = true;


    # Configure keymap in X11
    xkb.layout = "us";
    xkb.variant = "";

    displayManager = {
      gdm.enable = true;
    };
  };
  services.desktopManager.plasma6.enable = true;

  programs.ssh.askPassword = pkgs.lib.mkForce "${pkgs.ksshaskpass.out}/bin/ksshaskpass";

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

  services.syncthing = {
    enable = true;
    user = "ormoyo";
  };

  programs.nix-ld.enable = true;
  # Enable CUPS to print documents.
  services.printing.enable = true;

  hardware = {
    pulseaudio.enable = false;
    bluetooth.enable = true;
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  programs.adb.enable = true;
  programs.zsh.enable = true;

  services.xserver.libinput.enable = true;

  users.users.ormoyo = {
    isNormalUser = true;
    description = "Ormoyo";
    extraGroups = [ "networkmanager" "wheel" "adbusers" ];
    shell = pkgs.zsh;
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; lib.mkDefault [
      xdg-desktop-portal-gtk
    ];
  };

  environment.pathsToLink = [ "/share/xdg-desktop-portal" "/share/applications" ];
  environment.localBinInPath = true;

  home-manager = {
    extraSpecialArgs = { inherit inputs; };

    useUserPackages = true;
    useGlobalPkgs = true;

    users = {
      ormoyo = import ./home/home.nix;
    };
  };

  nixpkgs.config.allowUnfree = true;
  services.udev.packages = [ pkgs.yubikey-personalization ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
  system.activationScripts = {
    rmFirefoxContainers =
      ''
        rm -f /home/*/.mozilla/firefox/*/containers.json
      '';
    rmFirefoxSearch =
      ''
        rm -f /home/*/.mozilla/firefox/*/search.json*
      '';
  };
}
