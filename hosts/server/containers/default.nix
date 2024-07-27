{ pkgs, inputs, config, lib, ... }:
let
  DOCKER_PATH = "/mnt/disk2/docker";
  docker = config.virtualisation.oci-containers.backend;
  dockerBin = "${pkgs.${docker}}/bin/${docker}";
  create = name: { 
    name = name; 
    value = {
      serviceName = name;
      settings = import "${toString ./.}/${name}.nix"  { path = "${DOCKER_PATH}/${name}"; name = name; id = 995; inherit pkgs; };
    };
  };
  create-option = name: {
    name = name;
    value = {
      enable = lib.mkEnableOption "${name} service";
    };
  };
  step1 = (lib.lists.remove "default.nix" (builtins.attrNames (builtins.readDir ./.)));
  step2 = map (file: builtins.replaceStrings [".nix"] [""] file) step1;
  containers = map (file: create "${file}") step2;
in {
#  users.extraUsers.ormoyo.extraGroups = [ "podman" ];
  environment.systemPackages = with pkgs; [ 
    arion
#    docker-client
  ];

  virtualisation = {
    docker.enable = true;
    arion = {
      backend = "docker";
      projects = builtins.listToAttrs containers;

#      projects.nginx = {
#        serviceName = "nginx"; 
#        settings = import ./nginx.nix { path = "${DOCKER_PATH}/nginx"; config = config.virtualisation.arion.projects.nginx.settings; };
#      };


#      projects.nextcloud = {
#         serviceName = "nextcloud";
#         settings = import ./nextcloud.nix { path = "${DOCKER_PATH}/nextcloud"; config = config.virtualisation.arion.projects.nginx.settings; };
#      }; 
#    };
#    podman = {
#      enable = true;
#
#      # Create a `docker` alias for podman, to use it as a drop-in replacement
#      dockerCompat = true;
#      dockerSocket.enable = true;
#
#      # Required for containers under podman-compose to be able to talk to each other.
#      defaultNetwork.settings.dns_enabled = true;
#    };
    };
  };
  system.activationScripts = {
    mkNET = ''
      ${dockerBin} network inspect main-nginx >/dev/null 2>&1 || ${dockerBin} network create main-nginx --subnet 172.20.0.0/16
    '';
    mkYoutubeVol = ''
      ${dockerBin} volume inspect youtube-piped-proxy >/dev/null 2>&1 || ${dockerBin} volume create youtube-piped-proxy
    '';
  };
}

