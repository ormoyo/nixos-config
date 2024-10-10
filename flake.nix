{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprcursor-phinger.url = "github:Jappie3/hyprcursor-phinger";
    hyprcursor.url = "github:hyprwm/hyprcursor";
    hypridle.url = "github:hyprwm/hypridle";
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    hyprlock.url = "github:hyprwm/hyprlock";
    hyprpicker.url = "github:hyprwm/hyprpicker";
    hyprxdg.url = "github:hyprwm/xdg-desktop-portal-hyprland";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    nh.url = "github:viperML/nh";
    nix-gaming.url = "github:fufexan/nix-gaming";
    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    arion.url = "github:hercules-ci/arion";
  };

  outputs = { self, nixpkgs, nixpkgs-stable, ... }@inputs:
    let
      system = "x86_64-linux";

      domain = "pc.org";
      mkSystem = { pkgs, hostname, stable ? false, enableHomeManager ? false }:
        (if stable then nixpkgs-stable else nixpkgs).lib.nixosSystem {
          system = system;
          specialArgs = { inherit inputs; };
          modules = [
            { networking = { hostName = hostname; domain = domain; }; }

            ./hosts/${hostname}/configuration.nix
            ./hosts/${hostname}/hardware-configuration.nix
            ./modules/nixos

            inputs.arion.nixosModules.arion
            inputs.nix-index-database.nixosModules.nix-index
          ] ++ nixpkgs.lib.optionals enableHomeManager
            [
              ./modules/home-manager
              inputs.home-manager.nixosModules.default
            ];
        };
    in
    {
      home-manager.sharedModules = [
        inputs.hyprcursor-phinger.homeManagerModules.hyprcursor-phinger
        inputs.nix-index-database.hmModules.nix-index
      ];

      nixosConfigurations.laptop = mkSystem {
        hostname = "laptop";
        pkgs = nixpkgs;
        enableHomeManager = true;
      };

      nixosConfigurations.server = mkSystem {
        hostname = "server";
        pkgs = nixpkgs-stable;
        stable = true;
      };
    };
}
