{ name, path, id, getSecret, ... }:
{
  project.name = name;
  host.uid = id;

  custom.secrets = [ "settings" ];
  services = {
    app.service = {
      container_name = name;
      image = "thijsvanloef/palworld-server-docker:latest";
      restart = "unless-stopped";
      networks = [ "frontend" ];
      env_file = [
        (getSecret "settings")
        (getSecret "TZ")
      ];
      ports = [
        "8211:8211/udp"
        "27015:27015/udp"
      ];
      volumes = [ "${path}/data:/palworld" ];
      stop_grace_period = "30s";
    };
  };
  enableDefaultNetwork = false;
  networks.frontend = {
    name = "main-nginx";
    external = true;
  };
}
