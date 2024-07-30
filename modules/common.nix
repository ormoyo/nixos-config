{ pkgs, lib, config, ... }:
let
  cfg = config.packages.common;
in
with lib;
{
  options.packages.common.enable = mkOption {
    type = types.bool;
    default = true;
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      vim
      nmap
      ethtool
      htop
      compsize
      openssl
      hdparm
      git
    ];
  };
}
