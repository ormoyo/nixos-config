{ pkgs, lib, inputs, config, outputs, ... }:
let
  inherit (lib) attrNames listToAttrs mapAttrs mkDefault mkIf nameValuePair optional;
  cfg = config.settings.home;
  users = map
    (name: nameValuePair name
      (import ./home.nix { inherit config inputs pkgs lib outputs; username = name; }))
    (attrNames config.settings.common.users);
in
{
  imports = [ ./options.nix ];
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

    users.users = mapAttrs
      (n: v: {
        shell = if cfg.zsh.enable then pkgs.zsh else null;
        extraGroups = [ "adbuser" ];
      })
      config.settings.common.users;

    home-manager = {
      extraSpecialArgs = { inherit inputs; };
      backupFileExtension = "b421ackfaifiodasjup129214";

      useUserPackages = true;
      useGlobalPkgs = true;

      users = listToAttrs users;
    };

    services.desktopManager.plasma6.enable = mkDefault true;
    services.displayManager.sessionPackages = mkIf cfg.hyprland.enable [ pkgs.hyprland ];

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
      xwayland.enable = true;
    };

    programs.steam = {
      enable = true;
      package = mkDefault (pkgs.steam.override {
        extraPkgs = pkgs: with pkgs; [
          xorg.libXcursor
          xorg.libXi
          xorg.libXinerama
          xorg.libXScrnSaver
          libpng
          libpulseaudio
          libvorbis
          stdenv.cc.cc.lib
          libkrb5
          keyutils
        ];
      });
      extraPackages = with pkgs; [
        mangohud
        gamescope
      ];
    };
    programs.adb.enable = true;
    programs.zsh.enable = cfg.zsh.enable;

    services.gnome.gnome-keyring.enable = true;
    security.pam.services.gdm.enableGnomeKeyring = true;

    xdg.portal = mkIf cfg.xdg.enable {
      enable = true;
      wlr.enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        kdePackages.xdg-desktop-portal-kde
      ];
    };

    nix.settings = {
      substituters = [ "https://nix-gaming.cachix.org" "https://hyprland.cachix.org" ];
      trusted-public-keys = [ "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4=" "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    };

    nixpkgs.config = {
      packageOverrides = pkgs: {
        nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
          inherit pkgs;
        };
      };
      permittedInsecurePackages = [
        "olm-3.2.16"
      ];
    };
  };
}
