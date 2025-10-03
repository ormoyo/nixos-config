{ config, lib, port, ... }:
let
  inherit (lib) mkIf;
  cfg = config.custom.services;
in
{
  config = mkIf (cfg.enable && cfg.fileserver.enable) {
    services.nginx.virtualHosts = {
      "files.${cfg.domain}" = {
        forceSSL = cfg.fileserver.forceSSL;
        enableACME = !cfg.fileserver.disableACME;

        locations."/".root = "/srv/public";
      };
    };
  };
}
