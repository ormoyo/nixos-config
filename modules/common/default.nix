{ pkgs, lib, config, inputs, ... }:
with lib;
let
  cfg = config.settings.common;
in
{
  imports = [ ./options.nix ];
  config = mkIf cfg.enable {
    boot.loader = mkIf cfg.grub.enable {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      grub = {
        efiSupport = true;
        device = "nodev";
      };
    };


    users.users = builtins.mapAttrs
      (n: v: {
        isNormalUser = true;
        description = v;
        extraGroups = [ "wheel" ];
      })
      cfg.users;

    environment.systemPackages = with pkgs; mkIf cfg.packages.enable [
      age
      android-tools
      compsize
      ethtool
      git
      gitui
      hdparm
      htop
      libsecret
      lua
      nmap
      openssl
      powertop
      ripgrep
      sops
    ];

    networking.networkmanager.enable = mkDefault true;

    # Programs
    programs.nix-ld.enable = true;
    programs.nh = {
      enable = true;
      package = inputs.nh.packages.${pkgs.system}.nh;
      clean.enable = true;
      clean.extraArgs = "--keep-since 5d --keep 9";
      flake = toString ./..;
    };

    programs.neovim = {
      enable = cfg.neovim.enable;
      viAlias = true;
      vimAlias = true;
      package =
        if cfg.neovim.enableNightly
        then inputs.neovim-nightly-overlay.packages.${pkgs.system}.default
        else pkgs.neovim;
    };

    # time
    services.automatic-timezoned.enable = !cfg.time.enable;
    time.timeZone = mkIf cfg.time.enable cfg.time.timezone;

    i18n = {
      defaultLocale = cfg.time.locale;
      extraLocaleSettings = {
        LC_ADDRESS = cfg.time.locale;
        LC_IDENTIFICATION = cfg.time.locale;
        LC_MEASUREMENT = cfg.time.locale;
        LC_MONETARY = cfg.time.locale;
        LC_NAME = cfg.time.locale;
        LC_NUMERIC = cfg.time.locale;
        LC_PAPER = cfg.time.locale;
        LC_TELEPHONE = cfg.time.locale;
        LC_TIME = cfg.time.locale;
      };
    };

    # Other
    nixpkgs.config.allowUnfree = true;
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
  };
}
