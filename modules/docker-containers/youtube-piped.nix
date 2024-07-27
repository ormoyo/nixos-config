{ name, path, id, ... }:
{
  project.name = name;
  host.uid = 0;
  services = {
    frontend.service = {
      container_name = "piped-frontend";
      image = "1337kavin/piped-frontend:latest";
      restart = "unless-stopped";
      depends_on = ["backend"];
      environment = {
        BACKEND_HOSTNAME = "pipedapi.amoyal.org";
      }; 
    };
    proxy.service = {
      container_name = "piped-proxy";
      image = "1337kavin/piped-proxy:latest";
      restart = "unless-stopped";
      volumes = [
        "proxy:/app/socket:rw"
      ];
      environment.UDS = 1;
    };
    backend.service = {
      container_name = "piped-backend";
      image = "1337kavin/piped:latest";
      restart = "unless-stopped";
      depends_on = ["postgres"];
      volumes = [
        "${path}/config.properties:/app/config.properties:ro"
      ];
    };
    nginx.service = {
      container_name = name;
      image = "nginx:mainline-alpine";
      restart = "unless-stopped";
      depends_on = [ "backend" "proxy" "frontend" ];
      networks = [ "default" "frontend" ];
      volumes = [
        {
          type = "bind";
          source = "${path}/nginx.conf";
          target = "/etc/nginx/nginx.conf:ro";
        }
        "${path}/ytproxy.conf:/etc/nginx/snippets/ytproxy.conf:ro"
        "${path}/nginx.d:/etc/nginx/conf.d:ro"
        "proxy:/var/run/ytproxy:rw"
      ];
    };
    postgres.service = {
      image = "postgres:15";
      restart = "unless-stopped";
      volumes = [
        "${path}/postgres:/var/lib/postgresql/data"
      ];
      environment = {
        POSTGRES_DB = "piped";
        POSTGRES_USER = "piped";
        POSTGRES_PASSWORD = "changeme";
      };
    };
  };
  docker-compose.volumes.proxy = {};
  networks.frontend = {
    name = "main-nginx";
    external = true;
  };
}
