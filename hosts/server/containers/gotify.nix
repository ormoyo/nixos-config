{ name, path, id, ... }: 
{
  project.name = name;
  host.uid = id;
  services = {
    app.service = {
      container_name = name;
      image = "gotify/server";
      restart = "unless-stopped";
      networks = [ "frontend" ];
      volumes = [ 
        "${path}/data:/data" 
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
