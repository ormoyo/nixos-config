{ inputs, self, ... }:
{
  flake-file.inputs.sops-nix.url = "github:Mic92/sops-nix";
  flake-file.inputs.sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  flake-file.inputs.home-manager.url = "github:nix-community/home-manager/master";

  flake.nixosModules.base = { config, lib, ... }:
  let inherit (lib) mapAttrs' mkDefault nameValuePair;
    cfg = config.settings;
  in
  {
    imports = [ inputs.sops-nix.nixosModules.sops ];

    users.users = builtins.mapAttrs
      (n: v: {
        hashedPasswordFile = config.sops.secrets."users/${n}/password".path;
      })
      cfg.users;

    sops = {
      age.keyFile = mkDefault "/var/lib/sops-nix/key.txt";

      defaultSopsFile = mkDefault (builtins.toPath (self.outPath + /secrets/${config.networking.hostName}.yaml));
      defaultSopsFormat = mkDefault "yaml";

      secrets = mapAttrs'
        (n: v:
          nameValuePair "users/${n}/password" {
            mode = "0400";
            neededForUsers = true;
          }
        )
        cfg.users;
    };
  };
}
