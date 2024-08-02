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

  environment.systemPackages = with pkgs; [
  ];
}
