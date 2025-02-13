{ pkgs, ... }:
{
  imports =
    [
      ./fonts.nix
      ./graphics.nix
      ./tools
      ./virtualization.nix
      ./build-machines.nix
    ];

  services.logind.extraConfig = ''
    HandlePowerKey=hibernate
    HandleLidSwitch=hibernate
  '';

  services.power-profiles-daemon.enable = false;
  services.thermald.enable = true;
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "performance";

      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "performance";

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
  services.libinput.enable = true;

  services.udev.packages = with pkgs; [ yubikey-personalization libu2f-host ];
  security.pam = {
    services = {
      login.u2fAuth = true;
      sudo.u2fAuth = true;
      gdm-password.u2fAuth = true;
    };
    u2f = {
      enable = true;
      settings = {
        cue = true;
        origin = "pc.org";
        appId = "pc.org";
        authFile = pkgs.writeText "u2f_keys"
          ''
            ormoyo:VcS4hSXGlWEzsioA4BxgWoHDVGYn2rFdxyPJGYEmPvo+pajdUEdhHJPWlr7B4e3VhNAmpNMXKc/9SSJP6h+MCg==,SSmCTMgYrqorzGg5w0Pi6gAEx48aKoP63BP/TmyxRdzWX0SND0zNYZbFPw7ErhwFdYXaDcZAL5Vlsc86zwq+Lg==,es256,+presence:J8Zz4HGOhbUMdsfRkLNLBFrx30J1j8nN6um8B1ZPjGefc/jRVvhDH85c2RnUHP9K/5N2G3n5ETSgTvsgipcljg==,7rRjwIt/Ra65pHtAbKf+VzUdJu+MV7z9dVxVdg6A5UOAWa3spfmQDXiNwISKZt90xZ4plrbE/SEJTugj9jD0lw==,es256,+presence
          '';
      };
    };
  };

  system.stateVersion = "23.11";
}
