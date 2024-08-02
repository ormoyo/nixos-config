{ pkgs, lib, config, inputs, ... }:
let
  cfg = config.settings.common;
  mkCommonEnableOption = name: lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Whether to enable ${name}";
  };
in
with lib;
{
  options.settings.common = { 
    enable = mkCommonEnableOption "common settings"; 
    grub.enable = mkCommonEnableOption "grub bootloader";

    neovim = mkOption {
      default = {};
      type = with types; submodule {
        options = {
          enable = mkCommonEnableOption "neovim";
          enableNightly = mkEnableOption "setting neovim to nightly version";
        };
      };
    };

    packages.enable = mkCommonEnableOption "common packages";
    time = mkOption {
      default = {};
      type = with types; submodule {
        options = {
          enable = mkCommonEnableOption "common time settings";
          timezone = mkOption {
            type = types.str;
            default = "Asia/Jerusalem";
          };
          locale = mkOption {
            type = types.str;
            default = "en_IL";
          };
        };
      };
    };
  };


  config = mkIf cfg.enable {
    boot.loader = mkIf cfg.grub.enable {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";    };
      grub = {
         efiSupport = true;
         device = "nodev";
      };
    };

    environment.systemPackages = with pkgs; mkIf cfg.packages.enable [
      age
      android-tools
      compsize
      ethtool
      git
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
    programs.neovim = {
      enable = cfg.neovim.enable;
      viAlias = true;
      vimAlias = true;
      package = lib.mkIf cfg.neovim.enableNightly 
        inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
    };

    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 5d --keep 9";
      flake = "/etc/nixos";
    };

    
    time.timeZone = mkIf cfg.time.enable cfg.time.timezone;
    i18n = {
      defaultLocale = "en_US.UTF-8";
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
  };
}
