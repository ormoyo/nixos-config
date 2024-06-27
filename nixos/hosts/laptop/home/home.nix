{ pkgs, inputs, ... }:
let
  gaming-pkgs = inputs.nix-gaming.packages.${pkgs.system};
in {
  imports = [
    inputs.nix-flatpak.homeManagerModules.default
    ./desktop.nix
    ./browser.nix
    ./shell.nix
  ];

  home.username = "ormoyo";
  home.homeDirectory = "/home/ormoyo";

  home.stateVersion = "23.11";
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    ark
    cpupower-gui
    element-desktop
    ferdium
    hakuneko
    gaming-pkgs.wine-ge
    gimp
    gnome-extension-manager
    gnome.gnome-tweaks
    jetbrains.idea-community-bin
    kalendar
    libreoffice
    moonlight-qt
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
    thunderbird
    vesktop
    wl-clipboard

    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  home.sessionPath = [ "$HOME/.cargo/bin" ];

  services.flatpak.enableModule = true;
  services.flatpak.remotes.flathub = "https://dl.flathub.org/repo/flathub.flatpakrepo";
  
  services.flatpak.packages = [
    "flathub:app/com.usebottles.bottles//stable"
    "flathub:app/com.valvesoftware.Steam//stable"
    "flathub:app/io.gitlab.librewolf-community//stable"
  ];

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
      passwordCommand = "secret-tool lookup email ormoyoo@proton.me";
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

  systemd.user.services.protonmail-bridge = {
    Unit.Description = "Runs protonmail-bridge";
    Install.WantedBy = ["default.target"];
    Service.ExecStart = "${pkgs.protonmail-bridge}/bin/protonmail-bridge -n";
  };
}

