{ cfg, lib, ... }@attrs:
let inherit (lib) mkIf mapAttrs' nameValuePair;
in
{
  imports = [ ./options.nix (import ./sops.nix { inherit (attrs) config inputs lib; }) (import ./time.nix { inherit cfg lib; }) (import ./programs.nix { inherit (attrs) cfg lib pkgs inputs; }) ];
  config = mkIf cfg.enable {
    boot.loader = mkIf cfg.grub.enable {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      grub = {
        efiSupport = true;
        device = "nodev";
      };
    };

    sops.secrets = mapAttrs'
      (n: v:
        nameValuePair "users/${n}/password" {
          mode = "0400";
          neededForUsers = true;
        }
      )
      cfg.users;
    users.users = builtins.mapAttrs
      (n: v: {
        isNormalUser = true;
        description = v;
        extraGroups = [ "wheel" ];
        hashedPasswordFile = attrs.config.sops.secrets."users/${n}/password".path;
      })
      cfg.users;

    # Other
    nixpkgs.config.allowUnfree = true;
    nix.settings.experimental-features = [ "nix-command" "flakes" "pipe-operators" ];
  };
}
