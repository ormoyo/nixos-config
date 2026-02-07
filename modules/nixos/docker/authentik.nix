{ name, path, id, getSecret, ... }:
{
  project.name = name;
  host.uid = id;

  custom.backups.exclude = [ "redis" ];
  custom.secrets = [ "secret-key" ];

  services = {
    server.service = {
      container_name = name;
      image = "ghcr.io/goauthentik/server:2024.4.1";
      restart = "unless-stopped";
      command = "server";
      networks = [ "default" "frontend" ];
      depends_on = [ "redis" "postgres" ];
      volumes = [ 
        "${path}/media:/media" 
        "${path}/custom-templates:/templates" 
      ];
      env_file = [ (getSecret "secret-key") ];
      environment = {
        AUTHENTIK_REDIS__HOST = "redis";
        AUTHENTIK_POSTGRESQL__HOST = "postgres";
        AUTHENTIK_POSTGRESQL__USER = "authentik";
        AUTHENTIK_POSTGRESQL__NAME = "authentik";
        AUTHENTIK_POSTGRESQL__PASSWORD = "authentik";
      };
    };
    worker.service = {
      image = "ghcr.io/goauthentik/server:2024.4.1";
      restart = "unless-stopped";
      command = "worker";
      depends_on = [ "redis" "postgres" ];
      user = "0";
      volumes = [
        "${path}/media:/media" 
        "${path}/certs:/certs" 
        "${path}/custom-templates:/templates" 
      ];
      env_file = [ (getSecret "secret-key") ];
      environment = {
        AUTHENTIK_REDIS__HOST = "redis";
        AUTHENTIK_POSTGRESQL__HOST = "postgres";
        AUTHENTIK_POSTGRESQL__USER = "authentik";
        AUTHENTIK_POSTGRESQL__NAME = "authentik";
        AUTHENTIK_POSTGRESQL__PASSWORD = "authentik";
      };
    };
    redis.service = {
      image = "docker.io/library/redis:alpine";
      command = "--save 60 1 --loglevel warning";
      restart = "unless-stopped";
      healthcheck = {
        test = ["CMD-SHELL" "redis-cli ping | grep PONG"];
        start_period = "20s";
        interval = "30s";
        retries = 5;
        timeout = "3s";
      };
      volumes = [ "${path}/redis:/data" ];
    };
    postgres.service = {
      image = "docker.io/library/postgres:12-alpine";
      restart = "unless-stopped";
      healthcheck = {
        test = ["CMD-SHELL" "pg_isready -d $${POSTGRES_DB} -U $${POSTGRES_USER}"];
        start_period = "20s";
        interval = "30s";
        retries = 5;
        timeout = "5s";
      }; 
      volumes = [ "${path}/postgres:/var/lib/postgresql/data" ];
      environment = {
        POSTGRES_DB = "authentik";
        POSTGRES_USER = "authentik";
        POSTGRES_PASSWORD = "authentik";
      };
    };
  };
  networks.frontend = {
    name = "main-nginx";
    external = true;
  };
}
