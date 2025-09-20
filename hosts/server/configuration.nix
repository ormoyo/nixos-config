{ pkgs, config, lib, ... }:
{
  imports = [
    (import ./disko.nix { 
      inherit lib;
      device = "/dev/sdc";
      otherDisks = [ "/dev/sda" "/dev/sdb" ];
    })
  ];
  networking.interfaces.enp1s0.wakeOnLan.enable = true;
  users.users.ormoyo = {
    openssh.authorizedKeys.keys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIDYqb9ThU8mCA+5+6hdtESjMBFa6qnBMi85yabDiAezPAAAABHNzaDo= ormoyo@arch.nice.org"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIHtPiDAln9vl7TaLTUfgl1vK4kmLBHDybLsLMNw9au4PAAAABHNzaDo= ormoyo@arch.nice.org"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIKqlg2zuqwOowyMdofApgZW2LVUuZTPG3b0mG0z8v0wOAAAABHNzaDo= ormoyo@laptop.pc.org"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIKo6r1FZPntiu1HByA3OUSX2O4konT62PLdp7RikrXXXAAAABHNzaDo= ormoyo@laptop.pc.org"
    ];
  };

  security.sudo.extraConfig = "Defaults lecture = never";
  custom.services = {
    enable = true;
    domain = "amoyal.org";
    hostname = "acme+admin";
    provider = "cloudflare";

    filebrowser.enable = true;
    fileserver.enable = true;
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

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

  sops.age.keyFile = "/nix/persist/var/lib/sops-nix/key.txt";

  fileSystems."/nix/persist".neededForBoot = true;
  environment.persistence."/nix/persist" = {
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/systemd/coredump"
      "/var/lib/nixos"
      "/var/lib/sops-nix"
      "/var/tmp"
      "/etc/nixos"
      "/etc/NetworkManager/system-connections"
      "/opt/containers"
    ];
    files = [
      # machine-id is used by systemd for the journal, if you don't persist this
      # file you won't be able to easily use journalctl to look at journals for
      # previous boots.
      "/etc/machine-id"
      "/etc/adjtime"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_rsa_key"
    ];
  };
}
