{ name, path, id, getSecret, ... }:
{
  project.name = name;
  host.uid = id;

  custom.secrets = [ "config" ];
  services = {
    prowlarr.service = {
      container_name = "prowlarr";
      image = "lscr.io/linuxserver/prowlarr:latest";
      restart = "unless-stopped";
      env_file = [ (getSecret "TZ") ];
      volumes = [
        "${path}/prowlarr:/config"
        "${path}/data:/data"
      ];
    };
    sonarr.service = {
      container_name = "sonarr";
      image = "lscr.io/linuxserver/sonarr:latest";
      restart = "unless-stopped";
      env_file = [ (getSecret "TZ") ];
      volumes = [
        "${path}/sonarr:/config"
        "${path}/data:/data"
      ];
    };
    radarr.service = {
      container_name = "radarr";
      image = "lscr.io/linuxserver/radarr:latest";
      restart = "unless-stopped";
      env_file = [ (getSecret "TZ") ];
      volumes = [
        "${path}/radarr:/config"
        "${path}/data:/data"
      ];
    };
    qbittorrent.service = {
      image = "lscr.io/linuxserver/qbittorrent:latest";
      restart = "unless-stopped";
      network_mode = "service:gluten";
      env_file = [ (getSecret "TZ") ];
      volumes = [
        "${path}/config:/config"
        "${path}/downloads:/downloads"
      ];
    };
    gluten.service = {
      container_name = "media-vpn";
      image = "ghcr.io/qdm12/gluetun";
      restart = "unless-stopped";
      networks = [ "frontend" "default" ];
      devices = [ "/dev/net/tun:/dev/net/tun" ];
      env_file = [ (getSecret "TZ") (getSecret "config") ];
      capabilities = {
        ALL = true;
        NET_ADMIN = true;
      };
    };
  };
}

