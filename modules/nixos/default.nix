{ config, pkgs, ... }@attrs:
{
  imports = [
    (import ./common { inherit (attrs) inputs lib; inherit pkgs config; cfg = config.settings.common; })
    ./backups.nix
    ./docker
  ];
}
