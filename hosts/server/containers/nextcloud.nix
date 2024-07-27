{ name, path, id, ... }:
{
  project.name = name;
  host.uid = id;
  services = {
    app.service = {
      container_name = name;
      image = "nextcloud:production-fpm";
      restart = "unless-stopped";
      networks = [ "default" "frontend" ];
      depends_on = [ "db" "cache" ];
      volumes = [ 
        "${path}/data:/var/www/html" 
      ];
      environment = {
        DB_HOST = "db";
        DB_PORT = "5432";
        DB_NAME = "nextcloud";
        DB_USER = "nextcloud";
        DB_PASSWORD = "postgres";
        REDIS_HOST = "cache";
      };
    };
    cache.service = {
      image = "redis:latest";
      restart = "unless-stopped";
      volumes = [
        "${path}/redis:/data"
      ];
    };
    db.service = {
      image = "postgres:latest";
      restart = "unless-stopped";
      volumes = [
        "${path}/database:/var/lib/postgresql/data"
      ];
      environment = {
        POSTGRES_DATABASE = "nextcloud";
        POSTGRES_USER = "nextcloud";
        POSTGRES_PASSWORD = "postgres";
      };
    };
  };
  networks.frontend = {
    name = "main-nginx";
    external = true;
  };
}
