{ config, lib, inputs, homeManager ? false, ... }:
let inherit (lib) mkDefault;
in
{
  imports = [ (if homeManager then inputs.sops-nix.homeManagerModules.sops else inputs.sops-nix.nixosModules.sops) ];
  sops = {
    age.keyFile = mkDefault "/var/lib/sops-nix/key.txt";

    defaultSopsFile = mkDefault ../../../secrets/${config.networking.hostName}.yaml;
    defaultSopsFormat = mkDefault "yaml";
  };
}
