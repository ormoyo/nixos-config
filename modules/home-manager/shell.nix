{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true; # enabled in oh-my-zsh

    dotDir = ".config/zsh";

    initExtra = ''
      test -f ~/.dir_colors && eval $(dircolors ~/.dir_colors)
      eval "$(direnv hook zsh)"
    '';

    shellAliases = {
      ".." = "cd ..";
      ll = "ls -l";
      please = "sudo";
      update = "sudo nixos-rebuild switch --flake /etc/nixos/#laptop";
      upgrade = "sudo nixos-rebuild switch --flake /etc/nixos/#laptop --upgrade";
      update-boot = "sudo nixos-rebuild boot --flake /etc/nixos/#laptop";
      upgrade-boot = "sudo nixos-rebuild boot --flake /etc/nixos/#laptop --upgrade";
      test = "sudo nixos-rebuild test --flake /etc/nixos/#laptop";
      test-upgrade = "sudo nixos-rebuild test --flake /etc/nixos/#laptop --upgrade";
    };

    plugins = [
      {
        # will source zsh-autosuggestions.plugin.zsh
        name = "zsh-autosuggestions";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-autosuggestions";
          rev = "v0.4.0";
          sha256 = "0z6i9wjjklb4lvr7zjhbphibsyx51psv50gm07mbb0kj9058j6kc";
        };
      }
      {
        name = "enhancd";
        file = "init.sh";
        src = pkgs.fetchFromGitHub {
          owner = "b4b4r07";
          repo = "enhancd";
          rev = "v2.2.1";
          sha256 = "0iqa9j09fwm6nj5rpip87x3hnvbbz9w9ajgm6wkrd5fls8fn8i5g";
        };
      }
    ];
  };

  programs.autojump.enable = true;
  programs.zoxide.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home.packages = with pkgs; [
    zsh-autosuggestions
    zsh-fast-syntax-highlighting
    nix-zsh-completions
  ];
}
