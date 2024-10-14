{ pkgs, config, lib, ... }:
let inherit (lib) attrByPath filterAttrs flatten hasAttrByPath lists mkEnableOption mkIf mkOption nameValuePair optional optionals partition types;
  docker = config.virtualisation.oci-containers.backend;
  dockerBin = "${pkgs.${docker}}/bin/${docker}";

  cfg = config.services.docker;

  dirFiles = builtins.attrNames (builtins.readDir ./.);

  step1 = lists.remove "default.nix" dirFiles;
  step2 = builtins.map (file: builtins.replaceStrings [ ".nix" ] [ "" ] file) step1;

  getUser = service: cfg.services.${service}.user;
  import_file = name:
    import "${toString ./.}/${name}.nix" {
      name = cfg.services.${name}.serviceName;
      id =
        if builtins.isString (getUser name)
        then config.users.users.${getUser name}.uid
        else (getUser name);
      cfg = cfg.services.${name};
      path = cfg.services.${name}.dataDir;
      getSecret = secret:
        if secret == "TZ"
        then config.sops.secrets."docker/TZ".path
        else config.sops.secrets."docker/${name}/${secret}".path;
      inherit pkgs;
      inherit config;
      inherit lib;
    };

  modules = builtins.listToAttrs (builtins.map (name: nameValuePair name (import_file name)) step2);
  create_option = name:
    nameValuePair
      name
      (mkOption {
        default = { };
        type =
          types.submodule {
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
                type = with types; either str ints.unsigned;
                default = cfg.user;
              };

              extraPaths = mkOption {
                type = types.listOf types.str;
                default = [ ];
              };
            } //
            (mkIf (hasAttrByPath [ "custom" "options" ] modules.${name}) (attrByPath [ "custom" "options" ] { } modules.${name}));
          };
      });

  options = builtins.map (name: create_option name) step2;
in
{
  options.services.docker = {
    enable = mkEnableOption "Ormoyo's docker module";

    dataPath = mkOption {
      type = types.str;
      default = "/opt/docker";
    };

    user = mkOption {
      type = with types; either str ints.unsigned;
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
        options = builtins.listToAttrs options;
      };
    };
  };

  config =
    let
      enabledModules = filterAttrs (name: value: cfg.services.${name}.enable) modules;
      services = builtins.mapAttrs
        (name: module: {
          serviceName = name;
          settings = filterAttrs (n: v: n != "custom") module;
        })
        enabledModules;

      exclusions = flatten (builtins.attrValues
        (builtins.mapAttrs
          (name: module:
            let
              isBackupEnabled =
                if hasAttrByPath [ "custom" "backups" "enable" ] module
                then module.custom.backups.enable
                else true;
              exclusions =
                optionals (hasAttrByPath [ "custom" "backups" "exclude" ] module)
                  module.custom.backups.exclude ++
                optional (!isBackupEnabled) "**";
            in
            (cfg.services.${name}.backups.exclude ++ exclusions)
          )
          enabledModules));
      paths = flatten (builtins.attrValues (builtins.mapAttrs (n: v: [ (cfg.services.${n}.dataDir) ] ++ cfg.services.${n}.extraPaths) enabledModules));
      secrets = flatten (builtins.attrValues
        (builtins.mapAttrs
          (name: module:
            let
              secrets =
                optionals (hasAttrByPath [ "custom" "secrets" ] module)
                  module.custom.secrets;
            in
            builtins.map
              (secret: nameValuePair "docker/${name}/${secret}" {
                owner = cfg.services.${name}.user;
                restartUnits = [ "${name}.service" ];
              })
              secrets
          )
          enabledModules));
    in
    mkIf cfg.enable {
      #  users.extraUsers.ormoyo.extraGroups = [ "podman" ];
      services.backups = mkIf cfg.backups.enable {
        enable = true;
        repos.docker = {
          paths = paths;
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
          projects = services;
        };
      };

      system.activationScripts = {
        mkNET = ''
          ${dockerBin} network inspect main-nginx >/dev/null 2>&1 || ${dockerBin} network create main-nginx --subnet 172.20.0.0/16
        '';
      };
    };
}
