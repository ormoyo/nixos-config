{ name, path, id, getSecret, ... }:
{
  project.name = name;
  host.uid = id;

  custom.secrets = [ "config" "secret-key" "url" ]; 
  services = {
    app.service = {
      container_name = name;
      image = "vikunja/vikunja";
      restart = "unless-stopped";
      networks = [ "default" "frontend" ];
      depends_on = [ "db" ];
      volumes = [
        {
          type = "bind";
          source = getSecret "config";
          target = "/etc/vikunja/config.yml";
        }
        "${path}/files:/app/vikunja/files"
      ];
      env_file = [ (getSecret "secret-key") (getSecret "url") ];
      environment = {
        VIKUNJA_DATABASE_TYPE = "postgres";
        VIKUNJA_DATABASE_PASSWORD = "vikunja";
        VIKUNJA_DATABASE_HOST = "db";
      };
    };
    db.service = {
      image = "postgres:17";
      restart = "unless-stopped";
      volumes = [ "${path}/database:/var/lib/postgresql/data" ];
      environment = {
        POSTGRES_DB = "vikunja";
        POSTGRES_USER = "vikunja";
        POSTGRES_PASSWORD = "vikunja";
        POSTGRES_HOST_AUTH_METHOD = "trust";
      };
      healthcheck = {
        test = [ "CMD-SHELL" "pg_isready -d $$POSTGRES_DB -U $$POSTGRES_USER" ];
        interval = "30s";
        retries = 5;
        timeout = "5s";
      };
    };
  };

  networks.frontend = {
    name = "main-nginx";
    external = true;
  };
}
