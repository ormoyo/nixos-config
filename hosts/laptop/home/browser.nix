{pkgs, inputs, ...}:
{
  home.activation = {
    create-symlink = ''
      if ! test -h $HOME/.librewolf; then
        ln -s $HOME/.mozilla/firefox $HOME/.librewolf
      fi
    '';
  };

  xdg.desktopEntries = {
    japanese-librewolf = {
      name = "Japanese Librewolf";
      genericName = "Web Browser";
      exec = "librewolf -p japanese %U";
      terminal = false;
      categories = [ "Application" "Network" "WebBrowser" ];
      mimeType = [ "text/html" "text/xml" ];
    };
  }; 

  home.packages = [pkgs.firefoxpwa pkgs.ungoogled-chromium]; 
  programs.firefox = {
    enable = true;
    package = (pkgs.librewolf.override {
      nativeMessagingHosts = [pkgs.firefoxpwa];
    });

    policies = {
      DisableFirefoxAccounts = false;
    };
    profiles.default = {
      settings = {
        "privacy.clearOnShutdown.history" = false;
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
        privateDefault = "Searx";
      };
    };
    profiles.japanese = {  
      id = 1;
      settings = {
        "privacy.clearOnShutdown.history" = false;
      };
      containersForce = true;
      containers = {
        Immersion = {
          color = "blue";
          icon = "fruit";
          id = 0;
        };
        Learning = {
          color = "purple";
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
        privateDefault = "Searx";
      };
    };
  };
}
