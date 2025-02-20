{ cfg, lib, ... }:
let
  inherit (lib)
    options
    types
    mkOption
    mkIf;
in
{
  options.settings.common.impermanence = mkOption {
    type = types.bool;
    default = false;
    description = "Whether to enable impermanence";
  };

  config = mkIf cfg.settings.impermanence {
    environment.persistence."/nix/persist/system" = {
      enable = true;
      hideMounts = true;
      directories = [
        "/var/log"
        "/var/lib/systemd/coredump"
        "/var/lib/nixos"
        "/var/tmp"
        "/etc/nixos"
        "/etc/NetworkManager/system-connections"
        "/opt/containers"
      ];
      files = [
        # machine-id is used by systemd for the journal, if you don't persist this
        # file you won't be able to easily use journalctl to look at journals for
        # previous boots.
        "/etc/machine-id"
        "/etc/adjtime"
      ];
    };
  };
}
