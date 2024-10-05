{ name, path, id, getSecret, ... }: 
{
  project.name = name;
  host.uid = id;
  services = {
    app.service = {
      container_name = name;
      image = "gotify/server";
      restart = "unless-stopped";
      networks = [ "frontend" ];
      env_file = [ (getSecret "TZ") ];
      volumes = [ 
        "${path}/data:/data" 
      ];
    };
  };
  enableDefaultNetwork = false;
  networks.frontend = {
    name = "main-nginx";
    external = true;
  };
}
