{ config, lib, ... }:
let
  cfg = config.services.backups;
  repo_secret = repo: file: sops.secrets."backups/repos/${repo}/${file}";
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
        };
      }));
    };
  };

  config =
    let
      user = config.users.users.backups;
      create_secret = repo: [
        {
          name = "backups/repo/${repo}/file";
          value = {
            mode = "0400";
            owner = user.name;
          };
        }
        {
          name = "backups/repo/${repo}/pass";
          value = {
            mode = "0400";
            owner = user.name;
          };
        }
      ];

      create_backup = { name, paths, time, persistent ? false, exclusions, ... }: {
        name = name;
        value = {
          user = user.name;
          initialize = true;

          repositoryFile = config.secrets."backups/repo/${name}/file".path;
          passwordFile = config.secrets."backups/repo/${name}/pass".path;

          paths = paths;

          exclude = exclusions;
          timerConfig = {
            OnCalendar = time;
            Persistent = persistent;
          };
        };
      };

      repos = builtins.attrNames cfg.repos;
      secrets = lib.lists.flatten (map (repo: create_secret repo) repos);
      backups = map
        (repo:
          let
            module = cfg.repos.${repo};
          in
          create_backup {
            name = repo;
            paths = module.paths;
            time = module.time;
            persistent = module.timePersistent;
            exclusions = module.exclude;
          })
        repos;
    in
    mkIf cfg.enable {
      users.users.backups = {
        isSystemUser = true;
        description = "Backups managment user";
        home = cfg.user.home;
        createHome = true;
      };

      sops.secrets."ssh/backups/key" = {
        mode = "0400";
        owner = user.name;
      };
      sops.secrets."ssh/backups/config" = {
        mode = "0400";
        owner = user.name;
        path = "${user.home}/.ssh/config";
      };

      sops.secrets = builtins.listToAttrs secrets;
      services.restic.backups = builtins.listToAttrs backups;
    };
}
