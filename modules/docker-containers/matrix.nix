{ name, path, id, ... }:
{
  project.name = name;
  host.uid = id;
  services = {
    app.service = {
      container_name = name;
      image = "matrixdotorg/synapse:latest";
      restart = "unless-stopped";
      networks = [ "default" "frontend" ];
      depends_on = [ "db" ];
      volumes = [
        "${path}/data:/data"
      ];
      environment = { };
    };

    db.service = {
      image = "postgres:latest";
      restart = "unless-stopped";
      volumes = [
        "${path}/database:/var/lib/postgresql/data"
      ];
      environment = {
        POSTGRES_DATABASE = "matrix";
        POSTGRES_USER = "matrix";
        POSTGRES_PASSWORD = "xa8hM86YWIGFzIRLdshxJEZ7t69ZzMrcyA0KD";
      };
    };
  };
  networks.frontend = {
    name = "main-nginx";
    external = true;
  };
}
