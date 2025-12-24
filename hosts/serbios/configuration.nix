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

}
