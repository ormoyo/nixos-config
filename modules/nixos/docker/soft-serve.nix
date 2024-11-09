{ name, path, id, getSecret, ... }:
{
  project.name = name;
  host.uid = id;

  custom.secrets = [ "admin-keys" ];
  services = {
    app.service = {
      container_name = name;
      image = "charmcli/soft-serve:latest";
      restart = "unless-stopped";
      ports = [ "23231:23231" ];
      volumes = [ "${path}:/soft-serve" ];
      env_file = [ (getSecret "admin-keys") ];
      environment.SOFT_SERVE_NAME = "My Cool Projects";
    };
  };
  enableDefaultNetwork = false;
}
