{ name, path, id, ... }: {
  project.name = name;
  host.uid = id;

  services = {
    app.service = {
      container_name = name;
      image = "syncstorage-rs:latest";
      restart = "unless-stopped";
      networks = [ "frontend" ];
      volumes = [ 
        "${path}/data:/data" 
      ];
      environment = {
        SYNC_HOST = "0.0.0.0";
        SYNC_MASTER_SECRET = "secret0";
        SYNC_SYNCSTORAGE__DATABASE_URL = "mysql://test:test@sync-db:3306/syncstorage";
        SYNC_TOKENSERVER__DATABASE_URL = "mysql://test:test@tokenserver-db:3306/tokenserver";
        SYNC_TOKENSERVER__RUN_MIGRATIONS = "true";
      };
    };
    sync-db.service = {
      image = "docker.io/library/mysql:5.7";
      command = "--explicit_defaults_for_timestamp";
      restart = "unless-stopped";
      volumes = [ 
        "${path}/sync-db:/var/lib/mysql"
      ];
      environment = {
        MYSQL_ROOT_PASSWORD = "random";
        MYSQL_DATABASE = "syncstorage";
        MYSQL_USER = "test";
        MYSQL_PASSWORD = "test";
      };
    };
    tokenserver-db.service = {
      image = "docker.io/library/mysql:5.7";
      command = "--explicit_defaults_for_timestamp";
      restart = "unless-stopped"; 
      volumes = [ 
        "${path}/token-db:/var/lib/mysql"
      ];
      environment = {
        MYSQL_ROOT_PASSWORD = "random";
        MYSQL_DATABASE = "tokenserver";
        MYSQL_USER = "test";
        MYSQL_PASSWORD = "test";
      };
    };
    mock-fxa-server.service = {
      image = "app:build";
      restart = "no"; 
      entrypoint = "sh scripts/start_mock_fxa_server.sh";
      environment = {
        MOCK_FXA_SERVER_HOST = "0.0.0.0";
        MOCK_FXA_SERVER_PORT = 6000;        
      };
    };
  };
  networks.frontend = {
    name = "main-nginx";
    external = true;
  };
}
