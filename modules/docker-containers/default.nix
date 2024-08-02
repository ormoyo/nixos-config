{ pkgs, inputs, config, lib, ... }:
let
  docker = config.virtualisation.oci-containers.backend;
  dockerBin = "${pkgs.${docker}}/bin/${docker}";
  cfg = config.services.docker;
  create = { name, user, path }: {
    name = name;
    value = {
      serviceName = name;
      settings = import "${toString ./.}/${name}.nix" { path = path; name = name; id = user; inherit pkgs; };
    };
  };
  create-option = name: {
    name = name;
    value = lib.mkOption {
      default = {};
      type = with lib.types; submodule {
        options = {
          enable = lib.mkEnableOption "Enable ${name} service";
          dataDir = lib.mkOption {
            type = lib.types.str;
            default = "${cfg.dataPath}/${name}";
          };
          user = lib.mkOption {
            type = lib.types.ints.unsign;
            default = cfg.user;
          };
        };
      };
    };
  };
  dirFiles = builtins.attrNames (builtins.readDir ./.); 
  step1 = lib.lists.remove "default.nix" dirFiles;
  step2 = map (file: builtins.replaceStrings [".nix"] [""] file) step1;
  options = map (name: create-option name) step2;
in
with lib;
{
  options.services.docker = {
    enable = mkEnableOption "Enables Ormoyo's docker module";
    dataPath = mkOption {
      type = types.str;
    };
    user = mkOption {
      type = types.ints.unsign;
      default = 1000;
    };
    containers = mkOption {
      default = {};

      description = "Contains all specific container options";
      example = {
        nginx.enable = false;
        nginx.user = 0;
        nginx.dataDir = "/var/nginx";
      };
      
      type = with types; submodule {
        options = builtins.listToAttrs options;
      };
    };
  };

  config = mkIf cfg.enable {
    #  users.extraUsers.ormoyo.extraGroups = [ "podman" ];
    environment.systemPackages = with pkgs; [
      arion
      #    docker-client

    ];

    virtualisation =
      let
        enabledContainers = (lib.lists.partition (file: cfg.containers."${file}".enable) step2).right;
        containers = map (file: create 
        { 
          name = "${file}"; 
          user = cfg.containers."${file}".user; 
          path = cfg.containers."${file}".dataDir; 
        }) enabledContainers;
      in
      {
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
  };
}

