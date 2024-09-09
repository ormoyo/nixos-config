{ lib, enableHomeManager, ... }:
{
  imports = [
    ./common
    ./backups.nix
    ./docker-containers
  ] ++ lib.optional enableHomeManager
    ./home;
}
