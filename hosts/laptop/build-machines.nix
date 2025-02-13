{ config, ... }:
{
  sops.secrets =
  let
    mkConf = name: {
      mode = "0400";
      path = "${config.users.users.root.home}/.ssh/config.d/${name}";
    };
    mkKey = name: {
      mode = "0400";
      path = "${config.users.users.root.home}/.ssh/${name}";
    };
  in {
    "ssh/configs/router" = mkConf "router"; 
    "ssh/configs/main-builder" = mkConf "main-builder"; 
    "ssh/keys/router1" = mkKey "router1"; 
    "ssh/keys/router2" = mkKey "router2";
    "ssh/keys/main-builder1" = mkKey "main-builder1";
    "ssh/keys/main-builder2" = mkKey "main-builder2";
  };

  system.activationScripts = {
    mkSshConf = ''
      echo "Include config.d/*" > ${config.users.users.root.home}/.ssh/config
    '';
  };

  nix = {
    distributedBuilds = true;
    buildMachines = [{
      hostName = "main-builder";
      system = "x86_64-linux";
      protocol = "ssh-ng";
      maxJobs = 8;
      speedFactor = 2;
      supportedFeatures = [
        "big-parallel"
        "benchmark"
        "kvm"
      ];
    }];

    settings = {
      trusted-substituters = [ "ssh-ng://main-builder" ];
      trusted-public-keys = [ "main-builder:SmKE+CHf1d5fPBqJwg8x9WL0JfD4N9deaE+4fJqWTeA=" ];
    };

    extraOptions = ''
      builders-use-substitutes = true
    '';
  };
}
