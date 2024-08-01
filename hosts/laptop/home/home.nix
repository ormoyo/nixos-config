{ pkgs, inputs, ... }:
let
  gaming-pkgs = inputs.nix-gaming.packages.${pkgs.system};
in {
  imports = [
#    inputs.nix-flatpak.homeManagerModules.default
    ./desktop.nix
    ./browser.nix
    ./shell.nix
  ];

  home.username = "ormoyo";
  home.homeDirectory = "/home/ormoyo";

  home.stateVersion = "23.11";
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    (vesktop.override { withSystemVencord = false; })

    ark
    cpupower-gui
    element-desktop
    filelight
    gaming-pkgs.wine-ge
    gimp
    gnome-extension-manager
    gnome.gnome-tweaks
    hakuneko
    jetbrains.idea-community-bin
    kalendar
    keepassxc
    libreoffice
    moonlight-qt
    mpv
    networkmanagerapplet
    nwg-look
    pavucontrol
    pinta
    planify
    prismlauncher
    protonmail-bridge
    qalculate-gtk
    qpwgraph
    steamPackages.steam-runtime
    stremio
    subtitlecomposer
    thunderbird
    trashy
    vlc
    wl-clipboard
    zoom

    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
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
    shellIntegration.enableZshIntegration = true;

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

  programs.neovim = {
    enable = true;
    package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
  };


  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };


  accounts.email.accounts = {
    ormoyo = {
      userName = "ormoyoo@proton.me";
      realName = "Ormoyo";
      primary = true;
      thunderbird.enable = true;
      passwordCommand = "${pkgs.libsecret}/bin/secret-tool lookup email ormoyoo@proton.me";
      imap = {
        host = "127.0.0.0";
        port = 1143;
        tls = {
          enable = true;
          useStartTls = true;
        };
      };
    };
  };

  systemd.user.services.mpris-proxy = {
      Unit.Description = "Mpris proxy";
      Install.After = [ "network.target" "sound.target" ];
      Install.WantedBy = [ "default.target" ];
      Service.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
  };

  systemd.user.services.protonmail-bridge = {
    Unit.Description = "Runs protonmail-bridge";
    Install.WantedBy = ["default.target"];
    Service.ExecStart = "${pkgs.protonmail-bridge}/bin/protonmail-bridge -n";
  };
}

