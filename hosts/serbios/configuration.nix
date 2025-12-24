{ pkgs, lib, ... }:
{
  imports = [
    (import ./disko.nix { 
      device = "/dev/nvme0n1";
    })
  ];
  services.udev.packages = with pkgs; [ yubikey-personalization libu2f-host ];
  security.pam = {
    services = {
      login.u2fAuth = true;
      sudo.u2fAuth = true;
      gdm-password.u2fAuth = true;
    };
    u2f = {
      enable = true;
      settings = {
        cue = true;
        origin = "pc.org";
        appId = "pc.org";
        authFile = pkgs.writeText "u2f_keys"
          ''
            ormoyo:VcS4hSXGlWEzsioA4BxgWoHDVGYn2rFdxyPJGYEmPvo+pajdUEdhHJPWlr7B4e3VhNAmpNMXKc/9SSJP6h+MCg==,SSmCTMgYrqorzGg5w0Pi6gAEx48aKoP63BP/TmyxRdzWX0SND0zNYZbFPw7ErhwFdYXaDcZAL5Vlsc86zwq+Lg==,es256,+presence:J8Zz4HGOhbUMdsfRkLNLBFrx30J1j8nN6um8B1ZPjGefc/jRVvhDH85c2RnUHP9K/5N2G3n5ETSgTvsgipcljg==,7rRjwIt/Ra65pHtAbKf+VzUdJu+MV7z9dVxVdg6A5UOAWa3spfmQDXiNwISKZt90xZ4plrbE/SEJTugj9jD0lw==,es256,+presence
          '';
      };
    };
  };
  
  sops.age.keyFile = "/nix/persist/var/lib/sops-nix/key.txt";

  fileSystems."/nix/persist".neededForBoot = true;
  environment.persistence."/nix/persist" = {
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib"
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
  system.stateVersion = "25.11";
}
