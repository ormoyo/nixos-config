{ config, pkgs, ... }@attrs:
let
  importModule = path: cfg: extra: import path (extra // { inherit config cfg pkgs; inherit (attrs) inputs lib; });
in
{
  imports = [
    (importModule ./common config.settings.common)
    (importModule ./backups.nix config.services.backups)
  ];
}
