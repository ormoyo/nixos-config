{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    hyprland.url = "github:hyprwm/Hyprland";
    hyprxdg.url = "github:hyprwm/xdg-desktop-portal-hyprland";
    hyprcursor.url = "github:hyprwm/hyprcursor";
    hyprpicker.url = "github:hyprwm/hyprpicker";
    hypridle.url = "github:hyprwm/hypridle";
    hyprlock.url = "github:hyprwm/hyprlock";
    hyprcursor-phinger.url = "github:Jappie3/hyprcursor-phinger";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:ormoyo1/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    nix-gaming.url = "github:fufexan/nix-gaming";
    nix-flatpak.url = "github:GermanBread/declarative-flatpak/stable";
    # nix-ld = { 
    #   url = "github:Mic92/nix-ld";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in { 
      home-manager.sharedModules = [
        inputs.sops-nix.homeManagerModules.sops
        inputs.nix-flatpak.homeManagerModules.nix-flatpak
        inputs.hyprcursor-phinger.homeManagerModules.hyprcursor-phinger
        inputs.nix-index-database.hmModules.nix-index
        {
          programs.command-not-found.enable = false;
          programs.nix-index = {
            enable = true;
            enableBashIntegration = true;
            enableZshIntegration = true;
          };
        }
      ];

      nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/laptop/configuration.nix
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
  };
}
