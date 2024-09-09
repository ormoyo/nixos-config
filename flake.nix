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
      pkgs = nixpkgs.legacyPackages.${system};

      domain = "pc.org";
      index = {
        programs.command-not-found.enable = nixpkgs.lib.mkDefault false;
        programs.nix-index = {
          enable = nixpkgs.lib.mkDefault true;
          enableBashIntegration = nixpkgs.lib.mkDefault true;
          enableZshIntegration = nixpkgs.lib.mkDefault true;
        };
      };
      sops = name: {
        sops.defaultSopsFile = nixpkgs.lib.mkDefault ./secrets/${name}.yaml;
        sops.defaultSopsFormat = nixpkgs.lib.mkDefault "yaml";

        sops.age.keyFile = nixpkgs.lib.mkDefault "/var/lib/sops-nix/key.txt";
      };

      mkSystem = { pkgs, hostname, enableHomeManager ? false }:
        pkgs.lib.nixosSystem {
          system = system;
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/${hostname}/configuration.nix
            ./hosts/${hostname}/hardware-configuration.nix
            (import ./modules { inherit enableHomeManager; })

            { networking = { hostname = hostname; domain = domain; }; }

            (sops hostname)
            index

            inputs.arion.nixosModules.arion
            inputs.nix-index-database.nixosModules.nix-index
            inputs.sops-nix.nixosModules.sops
          ] ++ nixpkgs.lib.optionals enableHomeManager
            [ inputs.home-manager.nixosModules.default ];
        };
    in
    {
      home-manager.sharedModules = [
        inputs.sops-nix.homeManagerModules.sops
        inputs.hyprcursor-phinger.homeManagerModules.hyprcursor-phinger
        inputs.nix-index-database.hmModules.nix-index
        index
      ];

      nixosConfigurations.laptop = mkSystem {
        hostname = "laptop";
        pkgs = nixpkgs;
        enableHomeManager = true;
      };

      nixosConfigurations.server = mkSystem {
        hostname = "server";
        pkgs = nixpkgs-stable;
      };
    };
}
