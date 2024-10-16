{ pkgs ? import <nixpkgs> }:
{
  buildInputs = with pkgs; [
    rustToolchain
    openssl
    pkg-config
    cargo
    cargo-deny
    cargo-edit
    cargo-watch
    rust-analyzer
  ];

  shellHook = ''
    alias ls=eza
    alias find=fd
  '';

  env = {
    RUST_SRC_PATH = "${pkgs.rustToolchain}/lib/rustlib/src/rust/library";
  };
}
