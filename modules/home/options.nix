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
    hyprland.enable = mkHomeEnableOption "hyprland";
    xdg.enable = mkHomeEnableOption "xdg";
    zsh.enable = mkHomeEnableOption "zsh";
  };
}

