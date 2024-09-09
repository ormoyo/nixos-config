{ lib, ... }:
with lib;
let
  mkHomeEnableOption = name: lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Whether to enable ${name}";
  };
in
{
  options.settings.home = {
    enable = mkHomeEnableOption "home manager";
    power = mkOption {
      default = { };
      type = types.submodule {
        options = {
          enable = mkEnableOption "power settings";
          enableThermald = mkOption {
            type = types.bool;
            default = false;
          };
          powerManager = mkOption {
            type = types.enum [ "tlp" "power-profiles-daemon" "auto-cpufreq" ];
            default = "tlp";
          };
        };
      };
    };
    hyprland.enable = mkHomeEnableOption "hyprland";
    xdg.enable = mkHomeEnableOption "xdg";
  };
}

