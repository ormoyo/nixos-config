{ outputs, ... }:
{
  imports = [
    ./common.nix
    ./backups.nix
    ./docker-containers
  ];
}
