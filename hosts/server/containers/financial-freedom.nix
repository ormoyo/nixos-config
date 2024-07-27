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
#      environment = {
#        APP_NAME = "Financial Freedom";
#        APP_ENV = "local";
#        APP_URL = "https://finance.amoyal.org";
#        APP_DEBUG = "false";
#        APP_KEY = "base64:LMOpEfx5HyUD7WQXfsS6DP/ZBt9eVNMyAGDfIIILTPE=";
#        VITE_APP_NAME = "Financial Freedom";
#        DB_CONNECTION = "sqlite";
#        DB_DATABASE = "/var/www/html/.infrastructure/volume_data/database.sqlite";
#        FINANCIAL_FREEDOM_ALLOW_REGISTRATION = "false";
#        LOG_CHANNEL = "stack"; 
#        BROADCAST_DRIVER = "log";   
#        CACHE_DRIVER = "file";
#        QUEUE_CONNECTION = "sync";
#        SESSION_LIFETIME = 120;
#        SESSION_DRIVER = "cookie";
#      };
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
