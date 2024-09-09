{ lib, ... }:
with lib;
let 
  mkCommonEnableOption = name: lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Whether to enable ${name}";
  };
in 
{
  options.settings.common = {
    enable = mkCommonEnableOption "common settings";
    grub.enable = mkCommonEnableOption "grub bootloader";

    users = mkOption {
      type = types.attrsOf (types.oneOf [ types.str types.sub ]);
      default = { ormoyo = "Ormoyo"; };
    };

    neovim = mkOption {
      default = { };
      type = with types; submodule {
        options = {
          enable = mkCommonEnableOption "neovim";
          enableNightly = mkEnableOption "setting neovim to nightly version";
        };
      };
    };

    packages.enable = mkCommonEnableOption "common packages";
    time = mkOption {
      default = { };
      type = with types; submodule {
        options = {
          enable = mkCommonEnableOption "common time settings";
          timezone = mkOption {
            type = types.str;
          };
          locale = mkOption {
            type = types.str;
            default = "en_US.UTF-8";
          };
        };
      };
    };
  };
}
