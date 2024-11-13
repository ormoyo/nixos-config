{ config, ... }@attrs:
let
  importModule = path: cfg: extra: import path (extra // { inherit config cfg; inherit (attrs) inputs lib pkgs; });
in
{
  imports = [
    (importModule ./common.nix config.settings.common)
    (importModule ./docker config.services.docker { path = ./docker; })
    (importModule ./backups.nix config.services.backups)
  ];
}
