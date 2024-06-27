{pkgs, inputs, ...}:
{
  home.activation = {
    create-symlink = ''
      if ! test -h $HOME/.librewolf; then
        ln -s $HOME/.mozilla/firefox $HOME/.librewolf
      fi
    '';
  };

  programs.firefox = {
    enable = true;
    package = pkgs.librewolf;

    profiles.default = {
      settings = {
        "privacy.resistFingerprinting" = true;
        "privacy.clearOnShutdown.history" = false;
      };


      containersForce = true;
      containers = {
        Personal = {
          color = "blue";
          icon = "fruit";
          id = 0;
        };
        Work = {
          color = "orange";
          icon = "briefcase";
          id = 1;
        };
      };

      search = {
        force = true;
        engines = {
          "Searx" = {
            urls = [{
              template = "https://searxng.site?q={searchTerms}";
            }];

            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@sx" ];
          };
        };
        default = "Searx";
      };
      extensions = [
      ];
    };
  };
}
