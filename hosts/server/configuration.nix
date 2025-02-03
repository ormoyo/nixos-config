{ pkgs, config, ... }:
{
  networking.interfaces.enp1s0.wakeOnLan.enable = true;
  users.users.ormoyo = {
    openssh.authorizedKeys.keys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIDYqb9ThU8mCA+5+6hdtESjMBFa6qnBMi85yabDiAezPAAAABHNzaDo= ormoyo@arch.nice.org"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIHtPiDAln9vl7TaLTUfgl1vK4kmLBHDybLsLMNw9au4PAAAABHNzaDo= ormoyo@arch.nice.org"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIKqlg2zuqwOowyMdofApgZW2LVUuZTPG3b0mG0z8v0wOAAAABHNzaDo= ormoyo@laptop.pc.org"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIKo6r1FZPntiu1HByA3OUSX2O4konT62PLdp7RikrXXXAAAABHNzaDo= ormoyo@laptop.pc.org"
    ];
  };

  services.docker = {
    enable = true;
    user = "ormoyo";
    backups = {
      enable = true;
      time = "Mon,Sat 02:05";
    };
    services = {
      palworld.autoStart = false;
    };
  };
  sops.secrets."ssh/backups/config" = {
    mode = "0400";
    owner = config.users.users.backups.name;
    path = "${config.users.users.backups.home}/.ssh/config"; 
  };
  sops.secrets."ssh/backups/key" = {
    mode = "0400";
    owner = config.users.users.backups.name;
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  networking.firewall.allowedTCPPorts = [ 443 81 ];
  services.minecraft-servers = {
    enable = true;
    eula = true;
    servers = {
      furryIL = {
        autoStart = false;
        package = pkgs.forgeServers.forge-1_20_1;
        serverProperties = {
          server-port = 43000;
          difficulty = 3;
          max-players = 200;
        };
      };
    };
  };

  system.stateVersion = "23.11";
  powerManagement.powerUpCommands =
    ''
      ${pkgs.hdparm}/sbin/hdparm -B 128 -S 180 /dev/disk/by-uuid/f597bcf2-0d98-456f-9890-4b39f1069c2d
    '';
}
