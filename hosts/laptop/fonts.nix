{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.fcitx5 ];

  # Enable IME
  i18n.inputMethod = {
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
      ];
    };
  };

  fonts.packages = with pkgs; [
    corefonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    noto-fonts-extra
    nerd-fonts.hurmit
    ipafont
  ];
}
