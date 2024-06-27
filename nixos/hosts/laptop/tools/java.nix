{pkgs, ...}:
let
in {
  environment.systemPackages = with pkgs; [
    androidStudioPackages.beta
    openjdk17
    jdt-language-server
  ];

  programs.java = {
    enable = true;
  };
}
