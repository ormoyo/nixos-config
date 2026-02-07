{ name, path, id, config, pkgs, ... }:
let
  docker = config.virtualisation.oci-containers.backend;
  dockerBin = "${pkgs.${docker}}/bin/${docker}";
in
{
  project.name = name;
  host.uid = id;

  custom.activationScripts = {
    mkNET =
      ''
        ${dockerBin} network inspect main-nginx >/dev/null 2>&1 || ${dockerBin} network create main-nginx --subnet 172.20.0.0/16
      '';
  };

  services = {
    app.service = {
      container_name = name;
      image = "docker.io/jc21/nginx-proxy-manager:latest";
      restart = "unless-stopped";
      ports = [ "443:443" "80:80" "81:81" ];
      networks = [ "frontend" ];
      volumes = [
        "${path}/data:/data"
        "${path}/letsencrypt:/etc/letsencrypt"
        "${config.services.containers.services.nextcloud.dataDir}/data:/var/www/html"
      ];
    };
  };
  enableDefaultNetwork = false;
  networks.frontend = {
    name = "main-nginx";
    external = true;
  };
}
