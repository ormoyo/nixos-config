{ config, pkgs, lib, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
    ];

  networking.hostName = "server";
  networking.domain = "cooli.nice";

  networking.interfaces.enp1s0.wakeOnLan.enable = true;
  users.users.ormoyo = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
    uid = 1000;
    openssh.authorizedKeys.keys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIDYqb9ThU8mCA+5+6hdtESjMBFa6qnBMi85yabDiAezPAAAABHNzaDo= ormoyo@arch.nice.org"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIHtPiDAln9vl7TaLTUfgl1vK4kmLBHDybLsLMNw9au4PAAAABHNzaDo= ormoyo@arch.nice.org"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIFgtYocIFObw1brKFrWyHh8AvgNgCfAGgDSQSkFPHtoHAAAABHNzaDo= ormoyo@whipi.pc.org"
    ];
  };

  services.docker = {
    enable = true;
    dataPath = "/mnt/disk2/docker";
    user = "ormoyo";
    backups = {
      enable = true;
      time = "Mon,Sat 02:05";
      timePersistent = true;
    };
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
