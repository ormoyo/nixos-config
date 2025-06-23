{ config, lib, pkgs, ... }:
let
  inherit (lib) concatStringsSep mkIf mkOption types;
  cfg = config.custom.services;
  format = pkgs.formats.json { };
in {
  options.custom.services.filebrowser = {
    package = mkOption {
      type = types.package;
      default = pkgs.filebrowser;
    };

    settings = lib.mkOption {
      default = { };
      description = ''
        Settings for FileBrowser.
        Refer to <https://filebrowser.org/cli/filebrowser#options> for all supported values.
      '';
      type = types.submodule {
        freeformType = format.type;
        options = {
          address = lib.mkOption {
            default = "localhost";
            description = ''
              The address to listen on.
            '';
            type = types.str;
          };

          port = lib.mkOption {
            default = 8080;
            description = ''
              The port to listen on.
            '';
            type = types.port;
          };

          root = lib.mkOption {
            default = "/var/lib/filebrowser/data";
            description = ''
              The directory where FileBrowser stores files.
            '';
            type = types.path;
          };

          database = lib.mkOption {
            default = "/var/lib/filebrowser/database.db";
            description = ''
              The path to FileBrowser's Bolt database.
            '';
            type = types.path;
          };

          cache-dir = lib.mkOption {
            default = "/var/cache/filebrowser";
            description = ''
              The directory where FileBrowser stores its cache.
            '';
            type = types.path;
            readOnly = true;
          };
        };
      };
    };
  };

  config = mkIf (cfg.enable && cfg.filebrowser.enable) {
    systemd.services.filebrowser = {
      after = [ "network.target" ];
      description = "FileBrowser";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = let
          args = [
            (lib.getExe cfg.filebrowser.package)
            "--config"
            (format.generate "config.json" cfg.filebrowser.settings)
          ];
        in concatStringsSep " " args;

        StateDirectory = "filebrowser";
        CacheDirectory = "filebrowser";
        WorkingDirectory = cfg.filebrowser.settings.root;

        User = "filebrowser";
        Group = "filebrowser";
        UMask = "0077";

        NoNewPrivileges = true;
        PrivateDevices = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        MemoryDenyWriteExecute = true;
        LockPersonality = true;
        RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" ];
        DevicePolicy = "closed";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
      };
    };

    users.users.filebrowser = {
      group = "filebrowser";
      isSystemUser = true;
    };
    users.groups.filebrowser = { };
    systemd.tmpfiles.settings.filebrowser = {
      "${cfg.filebrowser.settings.root}".d = {
        user = "filebrowser";
        group = "filebrowser";
        mode = "0700";
      };
      "${cfg.filebrowser.settings.cache-dir}".d = {
        user = "filebrowser";
        group = "filebrowser";
        mode = "0700";
      };
      "${builtins.dirOf cfg.filebrowser.settings.database}".d = {
        user = "filebrowser";
        group = "filebrowser";
        mode = "0700";
      };
    };

    services.nginx = {
      virtualHosts = {
        "storage.${cfg.domain}" = {
          forceSSL = cfg.filebrowser.forceSSL;
          enableACME = !cfg.filebrowser.disableACME;
          locations."/" = { proxyPass = "http://localhost:${cfg.filebrowser.settings.port}"; };
        };
      };
    };
  };
}
