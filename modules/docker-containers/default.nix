{ pkgs, inputs, config, lib, ... }:
let
  docker = config.virtualisation.oci-containers.backend;
  dockerBin = "${pkgs.${docker}}/bin/${docker}";

  cfg = config.services.docker;

  dirFiles = builtins.attrNames (builtins.readDir ./.);

  step1 = lib.lists.remove "default.nix" dirFiles;
  step2 = map (file: builtins.replaceStrings [ ".nix" ] [ "" ] file) step1;

  getUser = container: cfg.containers.${container}.user;
  create_container = name:
    lib.nameValuePair
      name
      {
        serviceName = name;
        settings = lib.filterAttrs (n: v: n != "backups")
          (import "${toString ./.}/${name}.nix" {
            name = cfg.containers.${name}.serviceName;
            id =
              if builtins.isString (getUser name)
              then config.users.users.${getUser name}.uid
              else (getUser name);
            path = cfg.containers.${name}.dataDir;
            inherit pkgs;
            inherit config;
            inherit lib;
          });
      };
  create_option = name:
    lib.nameValuePair
      name
      (lib.mkOption
        {
          default = { };
          type = lib.types.submodule {
            options = {
              enable = lib.mkOption {
                type = lib.types.bool;
                default = true;
              };

              serviceName = lib.mkOption {
                type = lib.types.str;
                default = name;
              };

              dataDir = lib.mkOption {
                type = lib.types.str;
                default = "${cfg.dataPath}/${name}";
              };

              backups.exclude = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [ ];
              };

              user = lib.mkOption {
                type = with lib.types; either str ints.unsign;
                default = cfg.user;
              };
            };
          };
        });

  options = map (name: create_option name) step2;
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

    backups = mkOption {
      default = { };
      type = types.submodule {
        options = {
          enable = mkEnableOption "backing up docker dirs";

          time = mkOption {
            type = types.str;
          };
          timePersistent = mkOption {
            type = types.bool;
            default = true;
          };
        };
      };
    };

    containers = mkOption {
      default = { };

      description = "Contains all specific container options";
      example = {
        nginx.enable = false;
        nginx.user = 0;
        nginx.dataDir = "/var/nginx";
      };

      type = types.submodule {
        options = listToAttrs options;
      };
    };
  };

  config =
    let
      enabledContainers = (lib.partition (file: cfg.containers."${file}".enable) step2).right;
      containers = map (name: create_container name) enabledContainers;
      exclusions =
        lib.lists.flatten
          (map
            (container:
              let
                module = cfg.containers.${container};
                file = import "${toString ./.}/${container}.nix";
                isBackupEnabled =
                  if lib.hasAttrByPath [ "backups" "enable" ] file
                  then file.backups.enable
                  else true;
                exclusions =
                  lib.optionals (lib.hasAttrByPath [ "backups" "exclude" ] file)
                    file.backups.exclude ++
                  lib.optionals (!isBackupEnabled) [ "**" ];
              in
              map (exclusion: "${module.dataDir}/${exclusion}")
                (module.backups.exclude ++ exclusions)
            )
            enabledContainers);
    in
    mkIf cfg.enable {
      #  users.extraUsers.ormoyo.extraGroups = [ "podman" ];
      services.backups = mkIf cfg.backups.enable {
        enable = true;
        repos.docker = {
          paths = [ (cfg.dataPath) ];
          time = cfg.backups.time;
          timePersistent = cfg.backups.timePersistent;
          exclude = exclusions;
        };
      };

      virtualisation = {
        docker.enable = true;
        arion = {
          backend = "docker";
          projects = listToAttrs containers;
        };
      };

      system.activationScripts = {
        mkNET = ''
          ${dockerBin} network inspect main-nginx >/dev/null 2>&1 || ${dockerBin} network create main-nginx --subnet 172.20.0.0/16
        '';
      };
    };
}
