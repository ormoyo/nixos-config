{sops, ...}:

let
in 
{
  sops.secrets."syncthing_devices/device1" = {};
  networking.firewall.allowedTCPPorts = [ 8384 22000 ];
  networking.firewall.allowedUDPPorts = [ 22000 21027 ];
      
  services = {
    syncthing = {
      enable = true;
      user = "ormoyo";
      configDir = "/home/ormoyo/.config/syncthing";
      overrideDevices = true;
      overrideFolders = true;
      settings = {
        devices = {
	  server = { 
            id = "QHSYQCZ-PXQ5BNQ-QBNVPSJ-DP25PQE-FI27VOG-NEYVUU2-JOTCCON-AZE4BA2";
            addresses = [ "tcp://192.168.100.20:22000" ];
          };
	  desktop = { 
            id = "EIJLBXR-DB4VBKL-VGTIJNN-KVGAY2M-KIOF5R3-NPCP6A2-ABR576Y-4FEXHQD"; 
            addresses = [ "tcp://192.168.100.49:22000" ];
          };
          laptop1 = { id = "RSLMIDV-L4MHCGJ-LEOORTK-4JDH4XC-UJELNXQ-XDIKFVJ-NLZUVQE-BGBZ3QX"; };
          laptop2 = { id = "HRK5EH3-EMZWMFK-YHUOLCL-H4JONAM-XOGOCBG-XN37XJX-WNJTJSH-Q435DAU"; };
        };
        folders = {
          "nvim" = {
            path = "/home/ormoyo/.config/nvim";
            devices = [ "server" "desktop" "laptop1" "laptop2" ];
          };
          "projects" = {
            path = "/home/ormoyo/Projects";
            devices = [ "server" "desktop" "laptop1" "laptop2" ];
          };
        };
      };
    };
  };
}
