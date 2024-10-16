{ pkgs ? import <nixpkgs> }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    openssl
    pkg-config
    rustc
    cargo
    cargo-deny
    cargo-edit
    cargo-watch
    rust-analyzer
    libudev-zero
    egl-wayland
    wayland
    fontconfig
    freetype
    libGL
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
