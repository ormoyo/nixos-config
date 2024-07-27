{
  networking.firewall.allowedTCPPorts = [ 8384 22000 ];
  networking.firewall.allowedUDPPorts = [ 22000 21027 ];
  services = {
    syncthing = {
      enable = true;
      user = "ormoyo";
      dataDir = "/home/ormoyo/Documents";
      configDir = "/home/ormoyo/.config/syncthing";
      overrideDevices = true;     # overrides any devices added or deleted through the WebUI
      overrideFolders = true;     # overrides any folders added or deleted through the WebUI
      settings = {
        devices = {
          "device1" = { id = "EIJLBXR-DB4VBKL-VGTIJNN-KVGAY2M-KIOF5R3-NPCP6A2-ABR576Y-4FEXHQD"; };
        };
        folders = {
          "projects" = {         # Name of folder in Syncthing, also the folder ID
            path = "/home/ormoyo/Projects";    # Which folder to add to Syncthing
            devices = [ "device1" ];      # Which devices to share the folder with
          };
          "nvim" = {
            path = "/home/ormoyo/.config/nvim";
            devices = [ "device1" ];
          };
        };
      };
      guiAddress = "127.0.0.1:8384"; 
    };
  };
}
