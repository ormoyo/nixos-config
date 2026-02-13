{ inputs, ... }:
{
  flake.nixosModules.base = { config, lib, ... }: 
    let inherit (lib) mkIf mkOption types;
    in {
      options.settings.users = mkOption {
        default = {};
        type = types.attrsOf (types.either types.str 
        (types.submodule ({ name, ... }: {
          options = {
            description = mkOption {
              type = types.str;
            };
            isAdminUser = mkOption {
              type = types.bool;
              default = false;
            };
          };
        })));
        apply = builtins.mapAttrs (
          k: v: 
          if (builtins.isString v) 
          then {
            description = v;
            isAdminUser = false;
          }
          else v
        );
      }; 

      config = {
        users.users = builtins.mapAttrs
          (n: v: {
            isNormalUser = true;
            description = v.description;
            extraGroups = mkIf v.isAdminUser [ "wheel" ];
          })
          config.settings.users;
      };
  };
}
