{ cfg, lib, ... }:
let inherit (lib) mkIf;
in
{
  services.automatic-timezoned.enable = mkIf cfg.time.enable (cfg.time.timezone == null);
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
}
