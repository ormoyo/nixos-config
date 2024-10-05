{ pkgs, inputs, ... }:
let
  gaming-pkgs = inputs.nix-gaming.packages.${pkgs.system};
in
{
  home.stateVersion = "23.11";
  home.packages = with pkgs; [
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

