{ name, path, id, getSecret, ... }:
{
  project.name = name;
  host.uid = id;
  services = {
    app.service = {
      container_name = name;
      image = "quay.io/invidious/invidious:latest";
      restart = "unless-stopped";
      networks = [ "default" "frontend" ];
      depends_on = [ "db" ];
      env_file = [ (getSecret "config") ];
      healthcheck = {
        test = "wget -nv --tries=1 --spider http://127.0.0.1:3000/api/v1/trending || exit 1";
        interval = "30s";
        timeout = "5s";
        retries = 2;
      };
      logging.options = {
        max-size = "1G";
        max-file = "4";
      };
    };
    db.service = {
      image = "docker.io/library/postgres:14";
      restart = "unless-stopped";
      env_file = [ (getSecret "postgres") ];
      volumes = [
        {
          type = "bind";
          source = "${path}/init-invidious-db.sh";
          target = "/docker-entrypoint-initdb.d/init-invidious-db.sh";
        }
        "${path}/postgres:/var/lib/postgresql/data"
        "${path}/config/sql:/config/sql"
      ];
      healthchecks.test = [ "CMD-SHELL" "pg_isready -U $$POSTGRES_USER -d $$POSTGRES_DB" ];
    };

    # Material frontend
    materialious.service = {
      container_name = "materialious";
      image = "wardpearce/materialious:latest";
      restart = "unless-stopped";
      networks = [ "frontend" ];
      env_file = [ (getSecret "invidious-url") ];
      environment = { 
        VITE_DEFAULT_RETURNYTDISLIKES_INSTANCE = "https://returnyoutubedislikeapi.com";
        VITE_DEFAULT_SPONSERBLOCK_INSTANCE = "https://sponsor.ajay.app";
        VITE_DEFAULT_DEARROW_INSTANCE = "https://sponsor.ajay.app";
        VITE_DEFAULT_DEARROW_THUMBNAIL_INSTANCE = "https://dearrow-thumb.ajay.app";
      };
    };
  };
  networks.frontend = {
    name = "main-nginx";
    external = true;
  };
  custom.secrets = [ "config" "postgres" "invidious-url" ];
}
