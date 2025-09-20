{ config, lib, port, ... }:
let
  inherit (lib) mkIf;
  cfg = config.custom.services;
in
{
  config = mkIf (cfg.enable && cfg.vaultwarden.enable) {
    sops.secrets."services/vaultwarden/admin-token" = { mode = "0400"; };
    sops.templates."vaultwarden-env".content = ''
      ADMIN_TOKEN=${config.sops.placeholder."services/vaultwarden/admin-token"}
    '';

    services.vaultwarden = {
      enable = true;
      environmentFile = config.sops.templates."vaultwarden-env".path;
      config = {
        DOMAIN = "https://vault.${cfg.domain}";
        SIGNUPS_ALLOWED = false;
        INVITATIONS_ALLOWED = false;
        SHOW_PASSWORD_HINT = false;
        ROCKET_PORT = port;
      };
    };

    services.nginx.virtualHosts = {
      "vault.${cfg.domain}" = {
        forceSSL = cfg.vaultwarden.forceSSL;
        enableACME = !cfg.vaultwarden.disableACME;
        locations."/" = {
          proxyPass = "http://localhost:${toString config.services.vaultwarden.config.ROCKET_PORT}";
          proxyWebsockets = true;
        };
      };
    };
  };
}
