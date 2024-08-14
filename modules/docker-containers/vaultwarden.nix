{ name, path, id, getSecret, ... }:
{
  project.name = name;
  host.uid = id;
  services = {
    app.service = {
      container_name = name;
      image = "vaultwarden/server:latest";
      restart = "unless-stopped";
      networks = [ "frontend" ];
      volumes = [
        "${path}/data:/data"
      ];
      env_file = [
        (getSecret "admin-token")
        (getSecret "domain")
        (getSecret "smtp")
      ];
      environment = {
        WEBSOCKET_ENABLED = "true";
        SIGNUPS_ALLOWED = "false";
      };
    };
  };
  enableDefaultNetwork = false;
  networks.frontend = {
    name = "main-nginx";
    external = true;
  };
}
