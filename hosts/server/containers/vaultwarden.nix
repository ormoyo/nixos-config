{ name, path, id, ... }:
let
  ADMIN_TOKEN=''aohFrCi6c9Vlg5XxCrenRq45incsOAfNYxP+q/0nR7xkYU304lqviNf0+bVHU5MB'';
  DOMAIN = "https://vault.amoyal.org";
in {
  project.name = name;
  host.uid = id;
  services = {
    app.service = {
      container_name = name;
      image = "vaultwarden/server:latest";
      restart = "unless-stopped";
      networks = [ "frontend" ];
      volumes = [ 
        "${path}/data:/data" 
      ];
      environment = {
        ADMIN_TOKEN = "${ADMIN_TOKEN}";
        WEBSOCKET_ENABLED = "true";
        SIGNUPS_ALLOWED = "false";
        DOMAIN = "${DOMAIN}";
        SMTP_HOST = "mail.smtp2go.com";
        SMTP_FROM = "no-reply@amoyal.org";
        SMTP_USERNAME = "no-reply@amoyal.org";
        SMTP_PASSWORD = "9MKL3InBh1nsTg8ydF7E7kQDxCAIkT9g25QB2";
      };
    };
  };
  enableDefaultNetwork = false;
  networks.frontend = {
    name = "main-nginx";
    external = true;
  };
}
