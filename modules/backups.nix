{ config, lib, ... }:
let
  cfg = config.services.backups;
  defaultExcludePatterns = [
    ".git"
    "tmp"
    "*-tmp"
    "*_tmp"
    "*.tmp"
  ];
in
with lib;
{
  options.services.backups = {
    enable = mkEnableOption "backup services";
    user.home = mkOption {
      type = types.str;
      default = "/var/lib/backups";
    };

    repos = mkOption {
      default = { };
      type = types.attrsOf (types.submodule ({ name, ... }: {
        options = {
          name = mkOption {
            type = types.str;
            default = name;
          };

          paths = mkOption {
            type = types.listOf types.str;
            default = [ ];
          };

          time = mkOption {
            type = types.str;
          };

          timePersistent = mkOption {
            type = types.bool;
            default = true;
          };

          exclude = mkOption {
            type = types.listOf types.str;
            default = [ ];
          };

          removeDefaultExcludes = mkOption {
            type = types.bool;
            default = false;
          };
        };
      }));
    };
  };

  config =
    let
      user = config.users.users.backups;
      secrets = concatMapAttrs
        (name: value: {
          "backups/repos/${name}/file" = {
            mode = "0400";
            owner = user.name;
          };
          "backups/repos/${name}/pass" = {
            mode = "0400";
            owner = user.name;
          };
        })
        cfg.repos;

      backups = mapAttrs
        (name: value: {
          user = user.name;
          initialize = true;

          repositoryFile = config.sops.secrets."backups/repos/${name}/file".path;
          passwordFile = config.sops.secrets."backups/repos/${name}/pass".path;

          paths = value.paths;

          exclude = value.exclude ++
            optionals (!value.removeDefaultExcludes)
              defaultExcludePatterns;
          timerConfig = {
            OnCalendar = value.time;
            Persistent = value.timePersistent;
          };
        })
        cfg.repos;
    in
    mkIf cfg.enable {
      users.groups.backups = { };
      users.users.backups = {
        isSystemUser = true;
        description = "Backups managment user";
        home = cfg.user.home;
        createHome = true;
        group = "backups";
      };

      systemd.tmpfiles.rules = [
        "d ${user.home}/.ssh 0700 ${user.name} ${user.group}"
      ] ++
      (builtins.map (path: "A+ ${path} - - - - m::r-x,u:backups:r-x")
        (flatten (
          mapAttrsToList
            (name: value: cfg.repos.${name}.paths)
            cfg.repos
        )));

      sops.secrets = secrets // {
        "ssh/backups/key" = {
          mode = "0400";
          owner = user.name;
        };
        "ssh/backups/config" = {
          mode = "0400";
          owner = user.name;
          path = "${user.home}/.ssh/config";
        };
      };
      services.restic.backups = backups;
    };
}
