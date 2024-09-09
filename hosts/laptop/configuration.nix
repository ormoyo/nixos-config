{ pkgs, inputs, config, ... }:
{
  imports =
    [
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

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.udev.packages = [ pkgs.yubikey-personalization libu2f-host ];
  security.pam = {
    services = {
      login.u2fAuth = true;
      sudo.u2fAuth = true;
      gdm-password.u2fAuth = true;
    };
    u2f = {
      enable = true;
      cue = true;
      origin = "pc.org";
      appId = "pc.org";
      authFile = pkgs.writeText "u2f_keys"
        ''
          ormoyo:VcS4hSXGlWEzsioA4BxgWoHDVGYn2rFdxyPJGYEmPvo+pajdUEdhHJPWlr7B4e3VhNAmpNMXKc/9SSJP6h+MCg==,SSmCTMgYrqorzGg5w0Pi6gAEx48aKoP63BP/TmyxRdzWX0SND0zNYZbFPw7ErhwFdYXaDcZAL5Vlsc86zwq+Lg==,es256,+presence:J8Zz4HGOhbUMdsfRkLNLBFrx30J1j8nN6um8B1ZPjGefc/jRVvhDH85c2RnUHP9K/5N2G3n5ETSgTvsgipcljg==,7rRjwIt/Ra65pHtAbKf+VzUdJu+MV7z9dVxVdg6A5UOAWa3spfmQDXiNwISKZt90xZ4plrbE/SEJTugj9jD0lw==,es256,+presence
        '';
    };
  };

  system.stateVersion = "23.11";
}
