{ inputs, ... }:
{
  flake.nixosModules.base = { config, lib, ... }:
  let inherit (lib) mkDefault mkEnableOption mkIf mkOption types;
    cfg = config.settings;
  in
  {
    options.settings.time = {
      enable = mkOption {
        description = "Whether to enable time settings";
        type = types.bool;
        default = true;
      };
      timezone = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      locale = mkOption {
        type = types.str;
        default = "en_US.UTF-8";
      };
    };

    config = mkIf cfg.time.enable {
      services.automatic-timezoned.enable = mkDefault (cfg.time.enable && (cfg.time.timezone == null));
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
    };
  };
}
