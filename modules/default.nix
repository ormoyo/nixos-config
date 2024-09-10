{ lib, enableHomeManager, ... }:
{
  imports = [
    ./common
    ./backups.nix
    ./docker
  ] ++ lib.optional enableHomeManager
    ./home;
}
