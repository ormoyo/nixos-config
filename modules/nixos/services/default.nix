{ lib, config, pkgs, ... }:
let
  inherit (lib) concatMapAttrs filterAttrs imap0 mapAttrs' mkEnableOption mkIf mkOption nameValuePair remove removeSuffix types;
  cfg = config.custom.services;
  port = 31575;
  containersSubnet = "172.161.10";
  containerAddrLast = 2;
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
    |> imap0 (i: name: import ./${name}.nix {
      inherit config lib pkgs;
      port = port + i;
      containerAddress = "${containersSubnet}.${containerAddrLast + i}";
    });

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
    networking.firewall.allowedTCPPorts = [ 443 80 ];
  };
}
