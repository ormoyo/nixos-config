{ pkgs ? import <nixpkgs> }:
pkgs.mkShell rec {
  buildInputs = with pkgs; [
    alsa-lib
    cargo-whatfeatures
    egl-wayland
    fontconfig
    freetype
    libGL
    libudev-zero
    libxkbcommon
    gtk3
    openssl
    pkg-config
    rust-analyzer
    rust-bin.stable.latest.default
    vulkan-loader
    xorg.libX11
    xorg.libX11.dev
    xorg.libXcursor
    xorg.libXi
    zlib
    wayland
    webkitgtk_4_1
  ];
  LD_LIBRARY_PATH = "${pkgs.lib.makeLibraryPath buildInputs}";

  shellHook = ''
    alias ls=eza
    alias find=fd
  '';
}
