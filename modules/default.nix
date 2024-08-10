{ outputs, ... }:
{
  imports = [
    ./common.nix
    ./backups.nix
    ./docker-containers
    ./syncthing.nix { inherit outputs; }
  ];
}
