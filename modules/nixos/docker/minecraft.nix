{ name, path, id, getSecret, ... }:
{
  project.name = name;
  host.uid = id;
  services = {
    app.service = {
      container_name = name;
      image = "itzg/minecraft-server";
      restart = "unless-stopped";
      networks = [ "frontend" ];
      ports = [ "25565:25565" ];
      volumes = [
        "${path}/data:/data"
      ];
      environment = {
        EULA = "true";
        MAX_MEMORY = "4G";
        TYPE = "VANILLA";
      };
    };
  };
  enableDefaultNetwork = false;
  networks.frontend = {
    name = "main-nginx";
    external = true;
  };
}
