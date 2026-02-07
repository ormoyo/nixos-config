{ name, path, id, getSecret, ... }:
{
  project.name = name;
  host.uid = id;
  enableDefaultNetwork = false;
  services = {
    app.service = {
      container_name = name;
      image = "lscr.io/linuxserver/qbittorrent:latest";
      restart = "unless-stopped";
      network_mode = "container:vpn";
      env_file = [ (getSecret "TZ") ];
      volumes = [
        "${path}/config:/config"
        "${path}/downloads:/downloads"
      ];
    };
  };
}
