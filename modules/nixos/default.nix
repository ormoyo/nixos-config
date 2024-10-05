{ config, lib, pkgs, ... }@attrs:
{
  imports = [
    (import ./common { inherit (attrs) pkgs inputs hostname lib; cfg = config.settings.common; })
    ./backups.nix
    ./docker
  ];
}
