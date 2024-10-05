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
      networks = [ "default" "cloudflare-tunnel" "frontend" ];
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

    cloudflare-tunnel.service = {
      container_name = "cloudflare-tunnel";
      image = "cloudflare/cloudflared";
      restart = "unless-stopped";
      command = "tunnel run";
      networks = [ "cloudflare-tunnel" ];
      env_file = [ (getSecret "tunnel-token") ];
    };
  };
  networks.frontend = {
    name = "main-nginx";
    external = true;
  };

  networks.cloudflare-tunnel = {  };
}
