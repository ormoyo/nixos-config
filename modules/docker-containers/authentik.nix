{ name, path, id, ... }:
let
  PG_PASS = "HVyLjeV+9cA/ZYtUr4DFpiBze7MYFGi/s5MFh4BFsXNdVdnU";
  SECRET_KEY = "Soy0ltOLAr4cyEnI4XD/EV2zPVZ+YFSN8iPbL+Xtxn9EyCm23i3vCKH4sORole8CTAWVfs5moVIzVh1K";
in {
  project.name = name;
  host.uid = id;

  custom.backups.exclude = [ "redis" ];
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
      environment = {
        AUTHENTIK_REDIS__HOST = "redis";
        AUTHENTIK_POSTGRESQL__HOST = "postgres";
        AUTHENTIK_POSTGRESQL__USER = "authentik";
        AUTHENTIK_POSTGRESQL__NAME = "authentik";
        AUTHENTIK_POSTGRESQL__PASSWORD = "${PG_PASS}";
        AUTHENTIK_SECRET_KEY = "${SECRET_KEY}";
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
      environment = {
        AUTHENTIK_REDIS__HOST = "redis";
        AUTHENTIK_POSTGRESQL__HOST = "postgres";
        AUTHENTIK_POSTGRESQL__USER = "authentik";
        AUTHENTIK_POSTGRESQL__NAME = "authentik";
        AUTHENTIK_POSTGRESQL__PASSWORD = "${PG_PASS}";
        AUTHENTIK_SECRET_KEY = "${SECRET_KEY}";
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
      volumes = [
        "${path}/redis:/data"
      ];
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
      volumes = [ 
        "${path}/postgres:/var/lib/postgresql/data"
      ];
      environment = {
        POSTGRES_DB = "authentik";
        POSTGRES_USER = "authentik";
        POSTGRES_PASSWORD = "${PG_PASS}"; 
      };
    };
    #db.service = {
    #  image = "jc21/mariadb-aria:latest";
    #  restart = "unless-stopped";
    #  volumes = [ "${toString ./.}/mysql:/var/lib/mysql" ];
    #  environment = {
    #    MYSQL_ROOT_PASSWORD = "npm";
    #    MYSQL_DATABASE = "npm";
    #    MYSQL_USER = "npm";
    #    MYSQL_PASSWORD = "npm";
    #    MARIADB_AUTO_UPGRADE = "1";
    #  };
    #};
  };
  networks.frontend = {
    name = "main-nginx";
    external = true;
  };
}
