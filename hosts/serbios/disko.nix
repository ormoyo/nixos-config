{ device ? throw "Set this to your disk device, e.g. /dev/disk/by-id/<disk-id>", ... }:
{
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
    };
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

                "/@persist-snapshots" = {
                  mountOptions =
                    [ "subvol=@persist-snapshots" "noatime" "compress-force=zstd" ];
                  mountpoint = "/nix/persist/.snapshots";
                };
              };
            };
          };
        };
      };
    };
    nodev = {
      "/" = {
        fsType = "tmpfs";
        mountOptions = [ "defaults" "size=30%" "mode=755" ];
      };
    };
  };
}
