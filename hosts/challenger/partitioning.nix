# sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount /tmp/basashi/hosts/challenger/partitioning.nix
{
  disko.devices = {
    disk.main = {
      device = "/dev/disk/by-id/nvme-eui.5cdfb8038100270a";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = ["umask=0077"];
            };
          };
          root = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = ["-f"];
              subvolumes = {
                "/" = {
                  mountpoint = "/";
                  mountOptions = ["subvol=root" "compress=zstd:1" "noatime"];
                };
                "/nix" = {
                  mountpoint = "/nix";
                  mountOptions = ["subvol=nix" "compress-force=zstd:1" "noatime"];
                };
                "/var" = {
                  mountpoint = "/var";
                  mountOptions = ["subvol=var" "compress=zstd:1" "noatime" "nodatacow" "nodatasum"];
                };
                "/home" = {
                  mountpoint = "/home";
                  mountOptions = ["subvol=home" "compress=zstd:1" "noatime"];
                };
                "/var/lib" = {
                  mountpoint = "/var/lib";
                  mountOptions = ["subvol=var/lib" "compress=zstd:1" "noatime"];
                };
              };
            };
          };
        };
      };
    };
  };
  swapDevices = [
    {
      device = "/var/swap";
      size = 16 * 1024;
    }
  ];
}
