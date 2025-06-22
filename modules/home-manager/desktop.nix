{ pkgs, inputs, ... }:
{
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };


  fonts.fontconfig.enable = true;
  gtk = {
    enable = true;
    theme = {
      name = "Materia-dark";
      package = pkgs.materia-theme;
    };
    font = {
      name = "Hurmit Nerd Font";
      package = pkgs.nerd-fonts.hurmit;
    };
    gtk2.extraConfig = "gtk-im-module=\"fcitx\"";
    gtk3.extraConfig.gtk-im-module = "fcitx";
    gtk4.extraConfig.gtk-im-module = "fcitx";
  };

  home.packages = with pkgs; [
    inputs.hyprcursor-phinger.packages.${pkgs.system}.default

    hyprlock
    hypridle
    hyprpicker

    protonup-qt

    appimage-run
    blueberry
    brightnessctl
    nemo
    cliphist
    dunst
    hyprshot
    libsForQt5.qt5ct
    nordic
    pamixer
    kdePackages.polkit-kde-agent-1
    qt6Packages.qt6ct
    rofi-wayland
    swww
    waybar
    waypaper
    xdg-desktop-portal-gtk
    xdg-desktop-portal-wlr
    ydotool

  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  # home.file = {
  #   ".config/hypr".source = ./dotfiles/hyprland;
  #   ".config/waybar".source = ./dotfiles/waybar;
  #   ".config/rofi".source = ./dotfiles/rofi;
  #
  #   ".local/bin/run-electron-wayland.sh".source = ./dotfiles/run-electron-wayland.sh;
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;


    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  #};

  home.sessionVariables = {
    EDITOR = "nvim";
    NIXOS_OZONE_WL = "1";
  };

  home.pointerCursor = {
    name = "phinger-cursors-light";
    package = pkgs.phinger-cursors;
    size = 30;
    gtk.enable = true;
  };
}
