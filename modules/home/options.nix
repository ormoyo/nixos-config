{ lib, ... }:
let inherit (lib) mkOption options types;
  mkHomeEnableOption = name: mkOption {
    type = types.bool;
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

