{ config, pkgs, ... }@attrs:
{
  imports = [
    (import ./common { inherit (attrs) inputs lib; inherit pkgs; cfg = config.settings.common; })
    ./backups.nix
    ./docker
  ];
}
