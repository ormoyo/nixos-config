{ name, path, id, getSecret, ... }:
{
  project.name = name;
  host.uid = id;
  custom.secrets = [ "tunnel-token" ];
  services = {
    app.service = {
      container_name = name;
      image = "matrixdotorg/synapse:latest";
      restart = "unless-stopped";
      networks = [ "default""frontend" ];
      depends_on = [ "db" ];
      volumes = [ "${path}/data:/data" ];
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
        POSTGRES_PASSWORD = "matrix";
      };
    };

    turn-server.service = {
      image = "ghcr.io/processone/eturnal:latest";
      restart = "unless-stopped";
      volumes = [
        {
          type = "bind";
          source = "${path}/turn/eturnal.yaml";
          target = "/etc/eturnal.yml:ro";
        }
        {
          type = "bind";
          source = "${path}/turn/tls/cert.pem";
          target = "/etc/eturnal/tls/cert.pem:ro";
        }
        {
          type = "bind";
          source = "${path}/turn/tls/key.pem";
          target = "/etc/eturnal/tls/key.pem:ro";
        }
      ];
    };
  };
  networks.frontend = {
    name = "main-nginx";
    external = true;
  };
}
