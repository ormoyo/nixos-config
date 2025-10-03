
{ config, lib, port, ... }:
let
  inherit (lib) mkIf mkOverride;
  cfg = config.custom.services;
in
{
  config = mkIf (cfg.enable && cfg.vikunja.enable) {
    sops.secrets."services/vikunja/jwt-secret" = { mode = "0400"; };
    sops.templates."vikunja-env".content = ''
      VIKUNJA_SERVICE_JWTSECRET=${config.sops.placeholder."services/vikunja/jwt-secret"}
    '';

    services.vikunja = {
      enable = true;
      environmentFiles = [config.sops.templates."vikunja-env".path];
      frontendScheme = "https";
      frontendHostname = "plan.${cfg.domain}";
      settings.interface = mkOverride (lib.modules.defaultOverridePriority - 1) "localhost:${toString config.services.vikunja.port}";
    };

    services.nginx.virtualHosts = {
      "plan.${cfg.domain}" = {
        forceSSL = cfg.vikunja.forceSSL;
        enableACME = !cfg.vikunja.disableACME;
        locations."/" = {
          proxyPass = "http://localhost:${toString config.services.vikunja.port}";
          proxyWebsockets = true;
        };
      };
    };
  };
}
