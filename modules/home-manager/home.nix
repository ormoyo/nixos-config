{ pkgs, inputs, username, config, lib, ... }:
let
  gaming-pkgs = inputs.nix-gaming.packages.${pkgs.system};
in
{
  imports = [
    (import  ../nixos/common/sops.nix {inherit config inputs lib; homeManager = true;})
    
    ../../hosts/${config.networking.hostName}/home/home.nix

    ./browser.nix
    ./desktop.nix
    ./shell.nix
    ./ssh.nix
  ];

  home.username = username;
  home.homeDirectory = "/home/${username}";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    (vesktop.override { withSystemVencord = false; })
    nil

    cpupower-gui
    filelight
    gaming-pkgs.wine-ge
    gimp
    hakuneko
    jetbrains.idea-community-bin
    kdePackages.ark
    keepassxc
    libreoffice
    mpv
    networkmanagerapplet
    nheko
    nwg-look
    pavucontrol
    planify
    prismlauncher
    protonmail-bridge
    qalculate-gtk
    qbittorrent
    qpwgraph
    stremio
    thunderbird
    trashy
    virtiofsd
    vlc
    wl-clipboard
  ];

  home.sessionPath = [ "$HOME/.cargo/bin" ];

  #  services.flatpak.enableModule = true;
  #  services.flatpak.remotes.flathub = "https://dl.flathub.org/repo/flathub.flatpakrepo";

  #  services.flatpak.packages = [
  #    "flathub:app/com.usebottles.bottles//stable"
  #    "flathub:app/dev.vencord.Vesktop//stable"
  #  ];

  services.gnome-keyring.enable = true;

  programs.kitty = {
    enable = true;
    font = {
      name = "Hermit";
      size = 10;
      package = pkgs.nerdfonts;
    };
  };

  programs.btop = {
    enable = true;
    settings = {
      color_theme = "HotPurpleTrafficLight.theme";
    };
  };

  systemd.user.services.protonmail-bridge = {
    Unit.Description = "Runs protonmail-bridge";
    Install.WantedBy = [ "default.target" ];
    Service.ExecStart = "${pkgs.protonmail-bridge}/bin/protonmail-bridge -n";
  };
}
