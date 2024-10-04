{ pkgs, inputs, ... }:
let
  gaming-pkgs = inputs.nix-gaming.packages.${pkgs.system};
in
{
  imports = [
    # inputs.nix-flatpak.homeManagerModules.default
    ./desktop.nix
    ./browser.nix
    ./shell.nix
  ];

  home.stateVersion = "23.11";
  home.packages = with pkgs; [
    (vesktop.override { withSystemVencord = false; })

    moonlight-qt
    subtitlecomposer
    youtube-music
  ];

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
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
}

