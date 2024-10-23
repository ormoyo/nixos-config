{ pkgs ? import <nixpkgs> }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    cargo
    cargo-deny
    cargo-edit
    cargo-watch
    clippy
    egl-wayland
    fontconfig
    freetype
    libGL
    libudev-zero
    openssl
    pkg-config
    rust-analyzer
    rustc
    rustfmt
    wayland
  ];

  LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
    pkgs.libxkbcommon
    pkgs.vulkan-loader
  ];

  shellHook = ''
    alias ls=eza
    alias find=fd
  '';
}
