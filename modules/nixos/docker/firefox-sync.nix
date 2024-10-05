{ name, path, id, ... }: {
  project.name = name;
  host.uid = id;

  services = {
    app.service = {
      container_name = name;
      image = "mozilla/syncserver:latest";
      restart = "unless-stopped";
      networks = [ "default" "frontend" ];
      depends_on = [ "sync-db" "tokenserver-db" ];
      environment = {
	      SYNC_HOST = "0.0.0.0";
	      SYNC_HUMAN_LOGS = 1;
	      SYNC_MASTER_SECRET = "MY_SECRET";
	      SYNC_DATABASE_URL = "mysql://MY_SYNC_MYSQL_USER:MY_SYNC_MYSQL_USER_PASSWORD@syncstorage-db:3306/syncstorage";
	      SYNC_TOKENSERVER__ENABLED = "true";
	      SYNC_TOKENSERVER__RUN_MIGRATIONS = "true";
	      SYNC_TOKENSERVER__NODE_TYPE = "mysql";
	      SYNC_TOKENSERVER__DATABASE_URL = "mysql://MY_TOKEN_MYSQL_USER:MY_TOKEN_MYSQL_USER_PASSWORD@tokenserver-db:3306/tokenserver";
	      SYNC_TOKENSERVER__FXA_EMAIL_DOMAIN = "api.accounts.firefox.com";
	      SYNC_TOKENSERVER__FXA_OAUTH_SERVER_URL = "https://oauth.accounts.firefox.com/v1";
	      SYNC_TOKENSERVER__FXA_METRICS_HASH_SECRET = "MY_OTHER_SECRET";
	      # I don't really know what this is doing
	      SYNC_TOKENSERVER__ADDITIONAL_BLOCKING_THREADS_FOR_FXA_REQUESTS = 2;
      };
    };
    sync-db.service = {
      image = "docker.io/library/mysql:5.7";
      command = "--explicit_defaults_for_timestamp";
      restart = "unless-stopped";
      volumes = [ 
        "${path}/sync-db:/var/lib/mysql"
      ];
      ports = [ "3306" ];
      environment = {
      	MYSQL_ROOT_PASSWORD = "MY_SYNC_MYSQL_ROOT_PASSWORD";
      	MYSQL_DATABASE = "syncstorage";
      	MYSQL_USER = "MY_SYNC_MYSQL_USER";
      	MYSQL_PASSWORD = "MY_SYNC_MYSQL_USER_PASSWORD";
      };
    };
    tokenserver-db.service = {
      image = "docker.io/library/mysql:5.7";
      command = "--explicit_defaults_for_timestamp";
      restart = "unless-stopped"; 
      volumes = [ 
        "${path}/token-db:/var/lib/mysql"
      ];
      ports = [ "3306" ];
      environment = {
      	MYSQL_ROOT_PASSWORD = "MY_TOKEN_MYSQL_ROOT_PASSWORD";
      	MYSQL_DATABASE = "tokenserver";
      	MYSQL_USER = "MY_TOKEN_MYSQL_USER";
      	MYSQL_PASSWORD = "MY_TOKEN_MYSQL_USER_PASSWORD";
      };
    };
  };
  networks.frontend = {
    name = "main-nginx";
    external = true;
  };
}
