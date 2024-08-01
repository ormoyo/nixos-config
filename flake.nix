{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprcursor-phinger.url = "github:Jappie3/hyprcursor-phinger";
    hyprcursor.url = "github:hyprwm/hyprcursor";
    hypridle.url = "github:hyprwm/hypridle";
    hyprland.url = "github:hyprwm/Hyprland";
    hyprlock.url = "github:hyprwm/hyprlock";
    hyprpicker.url = "github:hyprwm/hyprpicker"; 
    hyprxdg.url = "github:hyprwm/xdg-desktop-portal-hyprland";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
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

  outputs = { self, nixpkgs, ... }@inputs: {
    home-manager.sharedModules = [
      inputs.sops-nix.homeManagerModules.sops
      inputs.hyprcursor-phinger.homeManagerModules.hyprcursor-phinger
      inputs.nix-index-database.hmModules.nix-index
      {
        programs.command-not-found.enable = false;
        programs.nix-index = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
        };
        xdg.portal.enable = true;
      }
    ];

    nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        ./hosts/laptop/configuration.nix
        ./modules
        inputs.home-manager.nixosModules.default
        inputs.nix-index-database.nixosModules.nix-index

        {
          programs.command-not-found.enable = false;
          programs.nix-index = {
            enable = true;
            enableBashIntegration = true;
            enableZshIntegration = true;
          };
        }
      ];
    };
    nixosConfigurations.server = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        ./hosts/server/configuration.nix
        ./modules
        inputs.arion.nixosModules.arion
      ];
    };
  };
}
