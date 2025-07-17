{ config, lib, containerAddress, ... }:
let
  inherit (lib) concatStringsSep mkIf splitString sublist;
  cfg = config.custom.services;
in {
  config = mkIf (cfg.enable && cfg.authentik.enable) {
    sops.secrets."services/authentik/secret-key" = { mode = "0400"; };
    sops.templates."authentik-env".content = ''
      AUTHENTIK_SECRET_KEY=${config.sops.placeholder."services/authentik/secret-key"}
    '';

    containers.authentik =
    let
      subnet = containerAddress 
        |> splitString "."
        |> sublist 0 3
        |> concatStringsSep ".";
    in {
      autoStart = true;
      privateNetwork = true;
      hostAddress = "${subnet}.1";
      localAddress = containerAddress;
      bindMounts."${config.sops.templates."authentik-env".path}" = {
        isReadOnly = true;
      };
      config = { config, ... }: {
        services.authentik = {
          enable = true;
          environmentFile = config.sops.templates."authentik-env".path;
          settings.disable_startup_analytics = true;
        };

        networking.firewall = {
          enable = true;
          allowedTCPPorts = [ 80 ];
        };
      };
    };

    services.nginx = {
      virtualHosts = {
        "auth.${cfg.domain}" = {
          forceSSL = cfg.authentik.forceSSL;
          enableACME = !cfg.authentik.disableACME;
          locations."/" = { proxyPass = "http://${containerAddress}:80"; };
        };
      };
    };
  };
}
