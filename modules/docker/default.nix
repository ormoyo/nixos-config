{ pkgs, config, lib, ... }:

let inherit (lib) flatten hasAttrByPath listToAttrs mkEnableOption mkIf mkOption nameValuePair optional optionals partition types;

  docker = config.virtualisation.oci-containers.backend;
  dockerBin = "${pkgs.${docker}}/bin/${docker}";

  cfg = config.services.docker;

  dirFiles = builtins.attrNames (builtins.readDir ./.);

  step1 = lib.lists.remove "default.nix" dirFiles;
  step2 = builtins.map (file: builtins.replaceStrings [ ".nix" ] [ "" ] file) step1;

  getUser = service: cfg.services.${service}.user;
  import_file = name:
    import "${toString ./.}/${name}.nix" {
      name = cfg.services.${name}.serviceName;
      id =
        if builtins.isString (getUser name)
        then config.users.users.${getUser name}.uid
        else (getUser name);
      path = cfg.services.${name}.dataDir;
      getSecret = secret:
        if secret == "TZ"
        then config.sops.secrets."docker/TZ".path
        else config.sops.secrets."docker/${name}/${secret}".path;
      inherit pkgs;
      inherit config;
      inherit lib;
    };
  create_service = name:
    nameValuePair
      name
      {
        serviceName = name;
        settings = lib.filterAttrs (n: v: n != "custom")
          (import_file name);
      };
  create_option = name:
    nameValuePair
      name
      (mkOption
        {
          default = { };
          type = types.submodule {
            options = {
              enable = mkOption {
                type = types.bool;
                default = true;
              };

              serviceName = mkOption {
                type = types.str;
                default = name;
              };

              dataDir = mkOption {
                type = types.str;
                default = "${cfg.dataPath}/${name}";
              };

              backups.exclude = mkOption {
                type = types.listOf types.str;
                default = [ ];
              };

              user = mkOption {
                type = with types; either str ints.unsign;
                default = cfg.user;
              };
            };
          };
        });

  options = builtins.map (name: create_option name) step2;
in
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

    services = mkOption {
      default = { };

      description = "Contains all specific docker service options";
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
      enabledServices = (partition (file: cfg.services."${file}".enable) step2).right;
      services = builtins.map (name: create_service name) enabledServices;

      exclusions =
        flatten
          (builtins.map
            (name:
              let
                module = cfg.services.${name};
                file = import_file name;
                isBackupEnabled =
                  if hasAttrByPath [ "custom" "backups" "enable" ] file
                  then file.custom.backups.enable
                  else true;
                exclusions =
                  optionals (hasAttrByPath [ "custom" "backups" "exclude" ] file)
                    file.custom.backups.exclude ++
                  optional (!isBackupEnabled) "**";
              in
              builtins.map (exclusion: "${module.dataDir}/${exclusion}")
                (module.backups.exclude ++ exclusions)
            )
            enabledServices);

      secrets = flatten (builtins.map
        (name:
          let
            module = cfg.services.${name};
            file = import_file name;
            secrets =
              optionals (hasAttrByPath [ "custom" "secrets" ] file)
                file.custom.secrets;
          in
          builtins.map
            (secret: nameValuePair "docker/${name}/${secret}" {
              owner = module.user;
              restartUnits = [ "${name}.service" ];
            })
            secrets
        )
        enabledServices);
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

      sops.secrets = builtins.listToAttrs secrets // {
        "docker/TZ" = { mode = "0444"; };
      };

      virtualisation = {
        docker.enable = true;
        arion = {
          backend = "docker";
          projects = listToAttrs services;
        };
      };



      system.activationScripts = {
        mkNET = ''
          ${dockerBin} network inspect main-nginx >/dev/null 2>&1 || ${dockerBin} network create main-nginx --subnet 172.20.0.0/16
        '';
      };
    };
}
