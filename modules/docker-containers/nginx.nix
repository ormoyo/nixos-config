{ name, path, id, config, ... }:
let
  cfg = config.services.docker.containers;
in {
  project.name = name;
  host.uid = id;
  services = {
    app.service = {
      container_name = name;
      image = "docker.io/jc21/nginx-proxy-manager:2.9.22";
      restart = "unless-stopped";
      ports = [ "443:443" "80:80" "81:81" ];
      networks = ["frontend"];
      volumes = [
        "${path}/data:/data" 
        "${path}/letsencrypt:/etc/letsencrypt" 
        "${cfg.nextcloud.dataDir}/data:/var/www/html"
      ];
    };
  };
  enableDefaultNetwork = false;
  networks.frontend = {
    name = "main-nginx";
    external = true;
  };
}
