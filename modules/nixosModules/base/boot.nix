{ inputs, ... }:
{
  flake.nixosModules.base = { lib, cfg, ... }: { 
    boot.loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      grub = {
        efiSupport = true;
        device = "nodev";
      };
    };
  };
}
