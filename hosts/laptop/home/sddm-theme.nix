{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
      (callPackage ./sddm-theme {}).sddm-theme-dialog
  ];
}
