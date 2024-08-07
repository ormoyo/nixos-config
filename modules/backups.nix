{ config, lib, ... }:
let
  cfg = config.services.backups;
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
      secrets = lib.flatten (map
        (name: value: [
          (lib.nameValuePair
            "backups/repo/${name}/file"
            {
              mode = "0400";
              owner = user.name;
            })
          (lib.nameValuePair
            "backups/repo/${name}/pass"
            {
              mode = "0400";
              owner = user.name;
            })
        ])
        (attrNames cfg.repos));

      backups = mapAttrs
        (name: value: {
          user = user.name;
          initialize = true;

          repositoryFile = config.secrets."backups/repo/${name}/file".path;
          passwordFile = config.secrets."backups/repo/${name}/pass".path;

          paths = value.paths;

          exclude = value.exclude;
          timerConfig = {
            OnCalendar = value.time;
            Persistent = value.timePersistent;
          };
        })
        cfg.repos;
    in
    mkIf cfg.enable {
      users.users.backups = {
        isSystemUser = true;
        description = "Backups managment user";
        home = cfg.user.home;
        createHome = true;
        group = "backups";
      };

      users.groups.backups = { };

      sops.secrets = listToAttrs (secrets ++ [
        (nameValuePair "ssh/backups/key" {
          mode = "0400";
          owner = user.name;
        })
        (nameValuePair "ssh/backups/config" {
          mode = "0400";
          owner = user.name;
          path = "${user.home}/.ssh/config";
        })
      ]);
      services.restic.backups = backups;
    };
}
