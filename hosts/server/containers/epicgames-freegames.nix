{ name, path, id, ... }:
{
  project.name = name;
  host.uid = id;
  services = {
    app.service = {
      container_name = name;
      image = "charlocharlie/epicgames-freegames";
      restart = "unless-stopped";
      networks = [ "frontend" ];
      volumes = [ 
        {
          type = "bind";
          source = "${path}/config.json";
          target = "/usr/app/config/config.json";
        }
      ];
      environment.TZ = "Israel";
    };
  };
  enableDefaultNetwork = false;
  networks.frontend = {
    name = "main-nginx";
    external = true;
  };
}
