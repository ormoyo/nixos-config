{ name, path, id, getSecret, ... }:
{
  project.name = name;
  host.uid = id;
  services = {
    app.service = {
      container_name = name;
      image = "zweizs/anki-sync-server";
      restart = "unless-stopped";
      networks = [ "frontend" ];
      volumes = [ 
        "${path}/data:/data" 
      ];
      env_file = [ (getSecret "env") ];
    };
  };
  enableDefaultNetwork = false;
  networks.frontend = {
    name = "main-nginx";
    external = true;
  };
}
