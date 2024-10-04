{ pkgs, inputs, lib, cfg, ... }:
{

  environment.systemPackages = with pkgs; lib.mkIf cfg.packages.enable [
    age
    android-tools
    compsize
    ethtool
    git
    gitui
    hdparm
    htop
    libsecret
    lua
    nmap
    openssl
    powertop
    ripgrep
    sops
  ];

  networking.networkmanager.enable = lib.mkDefault true;

  programs.nix-ld.enable = true;
  programs.nh = {
    enable = true;
    package = inputs.nh.packages.${pkgs.system}.nh;
    clean.enable = true;
    clean.extraArgs = "--keep-since 5d --keep 9";
    flake = toString ./..;
  };

  environment.sessionVariables.EDITOR = lib.mkIf cfg.neovim.enable "nvim";
  programs.neovim = {
    enable = cfg.neovim.enable;
    viAlias = true;
    vimAlias = true;
    package =
      if cfg.neovim.enableNightly
      then inputs.neovim-nightly-overlay.packages.${pkgs.system}.default
      else pkgs.neovim-unwrapped;
  };
}
