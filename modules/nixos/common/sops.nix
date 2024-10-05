{ hostname, lib, ... }:
let inherit (lib) mkDefault;
in
{
  sops = {
    age.keyFile = mkDefault "/var/lib/sops-nix/key.txt";

    defaultSopsFile = mkDefault ../../secrets/${hostname}.yaml;
    defaultSopsFormat = mkDefault "yaml";
  };
}
