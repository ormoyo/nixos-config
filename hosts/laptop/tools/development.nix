
{pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    delta
    fd
    gcc
    git
    glib
    go
    distrobox
    gnumake
    libsoup_3
    nodejs
    openssl
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
