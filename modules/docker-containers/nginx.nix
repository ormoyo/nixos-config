{ name, path, id, config, ... }:
{
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
        "${config.services.docker.services.nextcloud.dataDir}/data:/var/www/html"
      ];
    };
  };
  enableDefaultNetwork = false;
  networks.frontend = {
    name = "main-nginx";
    external = true;
  };
}
