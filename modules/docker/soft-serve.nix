{ name, path, id, getSecret, ... }:
{
  project.name = name;
  host.uid = id;
  services = {
    app.service = {
      container_name = name;
      image = "charmcli/soft-serve:latest";
      restart = "unless-stopped";
      ports = [ "23231:23231" ];
      volumes = [
        "${path}:/soft-serve"
      ];
    };
  };
  enableDefaultNetwork = false;
}
