{ config, lib, ... }:
let
  cfg = config.services.syncthing;
  devs = {
    device1 = {
      id = "EIJLBXR-DB4VBKL-VGTIJNN-KVGAY2M-KIOF5R3-NPCP6A2-ABR576Y-4FEXHQD";
      addresses = [
        "udp://192.168.100.49:22000"
        "tcp://192.168.100.49:22000"
      ];
    };
    device2 = {
      id = "QHSYQCZ-PXQ5BNQ-QBNVPSJ-DP25PQE-FI27VOG-NEYVUU2-JOTCCON-AZE4BA2";
      addresses = [
        "udp://192.168.100.20:22000"
        "tcp://192.168.100.20:22000"
      ];
    };
    device3 = {
      id = "HRK5EH3-EMZWMFK-YHUOLCL-H4JONAM-XOGOCBG-XN37XJX-WNJTJSH-Q435DAU";
      addresses = [
        "udp://192.168.10.2:22000"
        "tcp://192.168.10.2:22000"
      ];
    };
  };

  folds = {
    projects = {
      path = "/home/${cfg.user}/Projects";
      devices = builtins.attrNames devs;
    };
    nvim = {
      path = "/home/${cfg.user}/.config/nvim";
      devices = builtins.attrNames devs;
    };
  };

  create_device = { name, id, addresses }: {
    name = name;
    value = {
      id = id;
      addresses = addresses;
    };
  };
in
with lib;
{
  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 22000 ];
    networking.firewall.allowedUDPPorts = [ 22000 ];

    sops.secrets."syncthing/cert" = {
      mode = "0400";
      owner = config.users.users.${cfg.user}.name;
    };
    sops.secrets."syncthing/key" = {
      mode = "0400";
      owner = config.users.users.${cfg.user}.name;
    };

    services.syncthing = {
      dataDir = "${config.users.users.${cfg.user}.home}/Documents";
      configDir = "${config.users.users.${cfg.user}.home}/.config/syncthing";
      cert = config.sops.secrets."syncthing/cert".path;
      key = config.sops.secrets."syncthing/key".path;
      overrideDevices = true;
      overrideFolders = true;
      settings = {
        options.urAccepted = -1;

        devices = devs;
        folders = folds;
      };
      guiAddress = "127.0.0.1:8384";
    };
  };
}
