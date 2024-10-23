{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";  
    };
    hercules-ci-effects = { 
      url = "github:hercules-ci/hercules-ci-effects";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs-stable";
      inputs.gitignore.follows = "gitignore";
    };
    gitignore = {
      url = "github:hercules-ci/gitignore.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };


    hyprlang = { 
      url = "github:hyprwm/hyprlang";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.hyprutils.follows = "hyprutils";
    };
    hyprutils = {
      url = "github:hyprwm/hyprutils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprcursor-phinger = { 
      url = "github:Jappie3/hyprcursor-phinger"; 
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hypridle = { 
      url = "github:hyprwm/hypridle"; 
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.hyprlang.follows = "hyprlang";
      inputs.hyprutils.follows = "hyprutils";
    };
    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1"; 
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.hyprlang.follows = "hyprlang";
      inputs.hyprutils.follows = "hyprutils";
      inputs.pre-commit-hooks.follows = "git-hooks";
    };
    hyprlock = { 
      url = "github:hyprwm/hyprlock"; 
      inputs.nixpkgs.follows = "nixpkgs"; 
      inputs.hyprlang.follows = "hyprlang";
      inputs.hyprutils.follows = "hyprutils";
    };
    hyprpicker = { 
      url = "github:hyprwm/hyprpicker"; 
      inputs.nixpkgs.follows = "nixpkgs"; 
      inputs.hyprutils.follows = "hyprutils";
    };

    nh = { 
      url = "github:viperML/nh";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
      inputs.nixpkgs-stable.follows = "nixpkgs-stable";
    };

    nix-gaming = {
      url = "github:fufexan/nix-gaming"; 
      inputs.nixpkgs.follows = "nixpkgs"; 
      inputs.flake-parts.follows = "flake-parts";
    };

    arion = { 
      url = "github:hercules-ci/arion";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.hercules-ci-effects.follows = "hercules-ci-effects";
    };

    neovim-nightly-overlay = { 
      url ="github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.hercules-ci-effects.follows = "hercules-ci-effects";
      inputs.git-hooks.follows = "git-hooks";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-stable, ... }@inputs:
    let
      system = "x86_64-linux";

      domain = "pc.org";
      overlays = [ inputs.hyprland.overlays.default inputs.nh.overlays.default ];
      mkSystem = { pkgs, hostname, enableHomeManager ? false }:
        pkgs.lib.nixosSystem {
          system = system;
          specialArgs = { inherit inputs; };
          modules = [
            { networking = { hostName = hostname; domain = domain; }; }
            { nixpkgs.overlays = overlays; } 

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
        supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
        forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
          pkgs = import nixpkgs {
            inherit system;
          };
        });

        dirFiles = builtins.readDir ./shells;
        files = nixpkgs.lib.filterAttrs (n: v: v == "regular" || v == "symlink") dirFiles;
        shells = pkgs: pkgs.lib.mapAttrs' (n: v: pkgs.lib.nameValuePair (builtins.replaceStrings [ ".nix" ] [ "" ] n) (import ./shells/${n} { inherit pkgs; })) files;
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
      };

      devShells = forEachSupportedSystem ({ pkgs }: shells pkgs); 
    };
}
