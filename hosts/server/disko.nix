{ device ? throw "Set this to your disk device, e.g. /dev/disk/by-id/<disk-id>"
, otherDisks ? [], lib ? (import <nixpkgs> {}).lib, ... }:
let
  inherit (lib) nameValuePair;
  genAttrs = f: names: builtins.listToAttrs (map (n: f n) names);

  # Convert hdds to device definitions
  devices = genAttrs (dev:
    let name = builtins.baseNameOf dev;
    in nameValuePair name {
      device = dev;
      type = "disk";
      content = {
        type = "lvm_pv";
        vg = "${name}_vg";
      };
    }) otherDisks;

  # Convert hdds to lvm volume group defenitions
  lvm_vgs = genAttrs (dev:
    let name = builtins.baseNameOf dev;
    in nameValuePair "${name}_vg" {
      type = "lvm_vg";
      lvs = {
        main = {
          size = "100%FREE";
          content = {
            type = "btrfs";
            subvolumes = {
              "/@" = {
                mountpoint = "/mnt/${name}";
                mountOptions = [ "compress=zstd" "noatime" ];
              };
              "/@snapshots" = {
                mountpoint = "/mnt/${name}/.snapshots";
                mountOptions = [ "compress=zstd" "noatime" ];
              };
            };
          };
        };
      };
    }) otherDisks;
in {
  disko.devices = {
    disk = {
      main = {
        inherit device;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            esp = {
              name = "ESP";
              size = "500M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            swap = {
              size = "4G";
              content = { type = "swap"; };
            };
            root = {
              name = "root";
              label = "nixos";
              size = "100%";
              content = {
                type = "lvm_pv";
                vg = "root_vg";
              };
            };
          };
        };
      };
    } // devices;
    lvm_vg = {
      root_vg = {
        type = "lvm_vg";
        lvs = {
          root = {
            size = "100%FREE";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];

              subvolumes = {
                "/@persist" = {
                  mountOptions =
                    [ "subvol=@persist" "noatime" "compress-force=zstd" ];
                  mountpoint = "/nix/persist";
                };

                "/@nix" = {
                  mountOptions =
                    [ "subvol=@nix" "noatime" "compress-force=zstd" ];
                  mountpoint = "/nix";
                };
              };
            };
          };
        };
      };
    } // lvm_vgs;
    nodev = {
      "/" = {
        fsType = "tmpfs";
        mountOptions = [ "defaults" "size=30%" "mode=755" ];
      };
    };
  };
}
