{ lib, config, ... }:
let inherit (lib) listToAttrs mkOption nameValuePair options types;
  configs = config.programs.ssh.configs;
in
{
  options.programs.ssh.configs = mkOption {
    type = types.listOf types.str;
    default = [ ];
  };

  config =
    let
      secrets = map
        (name: nameValuePair name {
          owner = "0400";
          path = "${config.home.homeDirectory}/.ssh/config.d/${name}";
        })
        configs;
    in
    mkIf (configs != [ ]) {
      programs.ssh.includes = [ "config.d/*" ];
      sops.secrets = listToAttrs secrets;
    };
}
