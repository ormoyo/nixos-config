{pkgs, ...}:
{
  imports = [
    ./development.nix
    ./java.nix
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];

  fonts.packages = with pkgs; [
    corefonts
  ];

  services.flatpak.enable = true;
  environment.systemPackages = with pkgs; [
    adb-sync
    age
    android-file-transfer
    atk
    devbox
    dioxus-cli
    killall
    libGL
    libsecret
    libGLU
    linuxKernel.packages.linux_6_1.cpupower 
    lua
    nmap
    pam_u2f
    powertop
    python311
    python311Packages.pip
    python311Packages.pyopengl
    qbittorrent
    ripgrep
    sops
    tor-browser-bundle-bin
    ungoogled-chromium
    vim
    virtiofsd
    youtube-music
    (pkgs.wrapFirefox (pkgs.firefox-unwrapped.override { pipewireSupport = true;}) {}) 
  ];
}
