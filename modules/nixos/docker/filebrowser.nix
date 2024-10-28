{ name, path, id, ... }:
{
  project.name = name;
  host.uid = id;
  services = {
    app.service = {
      container_name = name;
      image = "filebrowser/filebrowser";
      restart = "unless-stopped";
      networks = [ "frontend" ];
      volumes = [
        {
          type = "bind";
          source = "${path}/filebrowser.json";
          target = "/.filebrowser.json";
        }
        {
          type = "bind";
          source = "${path}/filebrowser.db";
          target = "/database.db";
        }
        "${path}/data:/srv" 
      ];
    };
  };
  enableDefaultNetwork = false;
  networks.frontend = {
    name = "main-nginx";
    external = true;
  };
}
