{ name, path, id, getSecret, ... }: 
{
  project.name = name;
  host.uid = id;

  custom.secrets = [ "config" ];
  services = {
    app.service = {
      container_name = name;
      image = "ghcr.io/qdm12/gluetun";
      restart = "unless-stopped";
      networks = [ "frontend" ];
      devices = [ "/dev/net/tun:/dev/net/tun" ];
      env_file = [ (getSecret "TZ") (getSecret "config") ];
      capabilities = {
        ALL = true;
        NET_ADMIN = true;
      };
    };
  };
  enableDefaultNetwork = false;
  networks.frontend = {
    name = "main-nginx";
    external = true;
  };
}
