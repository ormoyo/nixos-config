{ inputs, ... }:
{
  imports = [
    inputs.flake-file.flakeModules.nix-auto-follow
    inputs.flake-file.flakeModules.dendritic
  ];
}
