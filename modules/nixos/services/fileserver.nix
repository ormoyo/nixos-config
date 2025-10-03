{ config, lib, port, ... }:
let
  inherit (lib) mkIf;
  cfg = config.custom.services;
in
{
  config = mkIf (cfg.enable && cfg.fileserver.enable) {
    services.static-web-server = {
      enable = true;
      root = "/var/lib/public";
      listen = "localhost:${toString port}";
    };

    services.nginx.virtualHosts = {
      "files.${cfg.domain}" = {
        forceSSL = cfg.fileserver.forceSSL;
        enableACME = !cfg.fileserver.disableACME;
        locations."/" = {
          proxyPass = "http://${config.services.static-web-server.listen}";
          proxyWebsockets = true;
        };
      };
    };
  };
}
