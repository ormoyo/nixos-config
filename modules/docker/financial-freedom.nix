{ name, path, id, ... }:
{
  project.name = name;
  host.uid = id;
  services = {
    app.service = {
      container_name = name;
      image = "serversideup/financial-freedom:latest";
      restart = "unless-stopped";
      networks = [ "frontend" "default" ];
      volumes = [ 
        "${path}/private:/var/www/html/storage/app/private/" 
        "${path}/public:/var/www/html/storage/app/public/"
        "${path}/sessions:/var/www/html/storage/framework/sessions"
        "${path}/logs:/var/www/html/storage/logs"
        "${path}/database:/var/www/html/.infrastructure/volume_data/"
      ];
      env_file = ["${path}/.env"];
    };
    db.service = {
      image = "postgres:13.4-alpine";
    };
  };
  networks.frontend = {
    name = "main-nginx";
    external = true;
  };
}
