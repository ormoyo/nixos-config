{ name, path, id, getSecret, ... }:
{
  project.name = name;
  host.uid = id;

  custom.secrets = [ "oidc" "secret-key" "url" ];

  services = {
    app.service = {
      container_name = name;
      image = "ghcr.io/plankanban/planka:latest";
      restart = "unless-stopped";
      depends_on = [ "postgres" ];
      volumes = [
        "${path}/user-avatars:/app/public/user-avatars"
        "${path}/background-images:/app/public/project-background-images"
        "${path}/attachments:/app/private/attachments"
      ];
      env_file = [ (getSecret "oidc") (getSecret "secret-key") (getSecret "url") ];
      environment.DATABASE_URL = "postgres://postgres@postgres/planka";
    };

    postgres.service = {
      image = "postgres:latest";
      restart = "unless-stopped";
      volumes = [ "${path}/database:/var/lib/postgresql/data" ];
      environment = {
        POSTGRES_DB = "planka";
        POSTGRES_HOST_AUTH_METHOD = "trust";
      };
      healthcheck = {
        test = [ "CMD-SHELL" "pg_isready -U postgres -d planka" ];
        interval = "10s";
        retries = 5;
        timeout = "5s";
      };
    };
  };
}
