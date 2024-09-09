{ lib, enableHomeManager, ... }:
{
  imports = [
    ./common
    ./backups.nix
    ./docker-containers
  ] ++ lib.optionals enableHomeManager
  [ ./home ];
}
