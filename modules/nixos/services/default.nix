{ lib, config, ... }:
let
  inherit (lib) concatMapAttrs filterAttrs mapAttrs' mkEnableOption mkIf mkOption nameValuePair remove removeSuffix types;
  cfg = config.custom.services;
  services = builtins.readDir ./.
    |> mapAttrs' (n: v:
      nameValuePair (removeSuffix ".nix" n) {
        enable = mkEnableOption "${n} service";
        forceSSL = mkOption {
          type = types.bool;
          default = true;
        };
        disableACME = mkOption {
          type = types.bool;
          default = false;
        };
      })
    |> filterAttrs (n: v: n != "default");
in {
  imports = services
    |> builtins.attrNames
    |> map (name: ./${name}.nix);

  options.custom.services = {
    enable = mkEnableOption "custom services";
    hostname = mkOption { type = types.str; };
    domain = mkOption { type = types.str; };
    provider = mkOption { type = types.str; };
  } // services;

  config = mkIf cfg.enable {
    sops.secrets."services/env" = { mode = "0400"; };
    security.acme = {
      acceptTerms = true;
      defaults.email = "${cfg.hostname}@${cfg.domain}";
      certs = {
        "${cfg.domain}" = {
          domain = "*.${cfg.domain}";
          group = "nginx";
          dnsProvider = cfg.provider;
          environmentFile = config.sops.secrets."services/env".path;
        };
      };
    };
    services.nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
    };
  };
}
