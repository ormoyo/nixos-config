
{pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    delta
    fd
    gcc
    glib
    go
    distrobox
    gnumake
    libsoup_3
    pkg-config
    rubyPackages.gio2
    rust-analyzer
    rustup
    sad
    stdenv.cc.cc.lib
    webkitgtk_4_1
    xdo
    zlib
  ];
}
