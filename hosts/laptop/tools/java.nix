{pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    jetbrains-toolbox
    openjdk17
    jdt-language-server
  ];

  programs.java = {
    enable = true;
  };
}
