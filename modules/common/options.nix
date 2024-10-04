{ lib, ... }:
let inherit (lib) mkEnableOption mkOption options types;
  mkCommonEnableOption = name: mkOption {
    type = types.bool;
    default = true;
    description = "Whether to enable ${name}";
  };
in 
{
  options.settings.common = {
    enable = mkCommonEnableOption "common settings";
    grub.enable = mkCommonEnableOption "grub bootloader";

    users = mkOption {
      type = types.attrsOf types.str;
      default = { ormoyo = "Ormoyo"; };
    };

    neovim = mkOption {
      default = { };
      type = types.submodule {
        options = {
          enable = mkCommonEnableOption "neovim";
          enableNightly = mkEnableOption "setting neovim to nightly version";
        };
      };
    };

    packages.enable = mkCommonEnableOption "common packages";
    time = mkOption {
      default = { };
      type = types.submodule {
        options = {
          enable = mkCommonEnableOption "common time settings";
          timezone = mkOption {
            type = types.nullOr types.str;
            default = null;
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
