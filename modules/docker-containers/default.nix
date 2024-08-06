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
  dirFiles = builtins.attrNames (builtins.readDir ./.);
  step1 = lib.lists.remove "default.nix" dirFiles;
  step2 = map (file: builtins.replaceStrings [ ".nix" ] [ "" ] file) step1;
in
with lib;
{
  options.services.docker = {
    enable = mkEnableOption "Ormoyo's docker module";
    dataPath = mkOption {
      type = types.str;
    };
    user = mkOption {
      type = with types; either str ints.unsign;
      default = 1000;
    };
    containers = mkOption {
      default = { };

      description = "Contains all specific container options";
      example = {
        nginx.enable = false;
        nginx.user = 0;
        nginx.dataDir = "/var/nginx";
      };

      type = types.attrsOf (types.submodule ({ name, ... }: {
        options = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Whether to enable ${name} docker container";
          };

          serviceName = mkOption {
            type = types.str;
            default = name;
          };

          dataDir = mkOption {
            type = types.str;
            default = "${cfg.dataPath}/${name}";
          };

          user = mkOption {
            type = with types; either str ints.unsign;
            default = cfg.user;
          };
        };
      }));
    };
  };

  config = mkIf cfg.enable {
    #  users.extraUsers.ormoyo.extraGroups = [ "podman" ];
    environment.systemPackages = [
      inputs.arion.packages.arion
    ];

    virtualisation =
      let
        getUser = container: cfg.containers.${container}.user;
        enabledContainers = (lib.lists.partition (file: cfg.containers."${file}".enable) step2).right;
        containers = map
          (file: create
            {
              name = cfg.containers.${file}.serviceName;
              user =
                if builtins.isString (getUser file)
                then config.users.users.${getUser file}.uid
                else (getUser file);
              path = cfg.containers.${file}.dataDir;
            })
          enabledContainers;
      in
      {
        docker.enable = true;
        arion = {
          backend = "docker";
          projects = builtins.listToAttrs containers;
        };
      };

    system.activationScripts = {
      mkNET = ''
        ${dockerBin} network inspect main-nginx >/dev/null 2>&1 || ${dockerBin} network create main-nginx --subnet 172.20.0.0/16
      '';
    };
  };
}

