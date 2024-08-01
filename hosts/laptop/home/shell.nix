{pkgs, ...}:
{
  programs = {
    zsh = {
      enable = true;
      enableCompletion = true; # enabled in oh-my-zsh
      initExtra = ''
        test -f ~/.dir_colors && eval $(dircolors ~/.dir_colors)
      '';
      shellAliases = {
        ne = "nix-env";
        ni = "nix-env -iA";
        no = "nixops";
        ns = "nix-shell --pure";
        please = "sudo";
        nix-switch = "sudo nixos-rebuild switch --flake /etc/nixos/#laptop";
        nix-switch-upgrade = "sudo nixos-rebuild switch --flake /etc/nixos/#laptop --upgrade";
        nix-boot = "sudo nixos-rebuild boot --flake /etc/nixos/#laptop";
        nix-boot-upgrade = "sudo nixos-rebuild boot --flake /etc/nixos/#laptop --upgrade";
        nix-test = "sudo nixos-rebuild test --flake /etc/nixos/#laptop";
        nix-test-upgrade = "sudo nixos-rebuild test --flake /etc/nixos/#laptop --upgrade";
      };
    };
    autojump.enable = true;
    zoxide.enable = true;
  };

  home.packages = with pkgs; [
    zsh-autosuggestions
    zsh-fast-syntax-highlighting
    nix-zsh-completions
  ];
}
