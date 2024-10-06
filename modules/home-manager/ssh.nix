{ lib, config, ... }:
let inherit (lib) listToAttrs mkIf mkOption nameValuePair options types;
in
{
  options.programs.ssh = {
    configs = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };

    keys = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
  };

  config =
    let
      configs = config.programs.ssh.configs;
      keys = config.programs.ssh.keys;
      secrets = (map
        (name: nameValuePair "ssh/configs/${name}" {
          mode = "0400";
          path = "${config.home.homeDirectory}/.ssh/config.d/${name}";
        })
        configs)
      ++ (map
        (name: nameValuePair "ssh/keys/${name}" {
          mode = "0400";
          path = "${config.home.homeDirectory}/.ssh/${name}";
        })
        keys);
    in
    mkIf (secrets != [ ]) {
      programs.ssh.includes = [ "config.d/*" ];
      sops.secrets = listToAttrs secrets;
    };
}
