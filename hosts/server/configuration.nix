{ config, pkgs, lib, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
    ];

  networking.hostName = "server";
  networking.domain = "amoyal.org";

  networking.interfaces.enp1s0.wakeOnLan.enable = true;
  environment.etc."zshsfas".source = "${pkgs.openssl}";

  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  users.users.ormoyo = {
    isNormalUser = true;
    description = "Ormoyo";
    extraGroups = [ "networkmanager" "wheel" ];
    uid = 1000;
  };

  services.docker = {
    enable = true;
    dataPath = "/mnt/disk2/docker";
    user = 1000;
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  services.syncthing = {
    enable = true;
    user = "ormoyo";
  };

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.firewall.allowedTCPPorts = [ 443 81 ];

  system.stateVersion = "23.11";
  powerManagement.powerUpCommands =
    ''
      ${pkgs.hdparm}/sbin/hdparm -B 128 -S 180 /dev/disk/by-uuid/f597bcf2-0d98-456f-9890-4b39f1069c2d
    '';
}
