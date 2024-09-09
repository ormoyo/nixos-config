{ pkgs, lib, inputs, config, ... }:
with lib;
let
  cfg = config.settings.home;
in
{
  config = mkIf cfg.enable {
    # Display manager
    services.xserver = {
      enable = true;

      xkb.layout = "us";
      xkb.variant = "";

      displayManager = {
        gdm.enable = true;
      };
    };

    environment.localBinInPath = mkDefault true;
    environment.pathsToLink =
      optional cfg.zsh.enable "/share/zsh";

    users.users = mkIf cfg.zsh.enable (mapAttrs
      (n: v: { shell = pkgs.zsh; })
      config.settings.common.users);

    home-manager = {
      extraSpecialArgs = { inherit inputs; };
      backupFileExtension = "backup";

      useUserPackages = true;
      useGlobalPkgs = true;

      users = mapAttrs (n: v: (import ./home/home.nix) // (import ../../hosts/home/home.nix));
    };

    services.desktopManager.plasma6.enable = mkDefault true;
    services.displayManager.sessionPackages = mkIf cfg.hyprland.enable [ inputs.hyprland.packages.${pkgs.system}.hyprland ];

    # Pipewire
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };

    # Programs
    programs.hyprland = mkIf cfg.hyprland.enable {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
      xwayland.enable = true;
      portalPackage = inputs.hyprxdg.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
    };

    programs.steam.enable = mkDefault true;
    programs.adb.enable = true;
    programs.zsh.enable = cfg.zsh.enable;

    services.gnome.gnome-keyring.enable = true;
    security.pam.services.gdm.enableGnomeKeyring = true;

    xdg.portal = mkIf cfg.xdg.enable {
      enable = true;
      wlr.enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
      ];
    };

    nix.settings = {
      substituters = [ "https://nix-gaming.cachix.org" ];
      trusted-public-keys = [ "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4=" ];
    };

    nixpkgs.config.packageOverrides = pkgs: {
      nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
        inherit pkgs;
      };
    };
  };
}
