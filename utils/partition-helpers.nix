# helpers for the partitioning modules
let
  mkBoot = { size ? "1G", priority ? 100 }: {
    inherit size priority;
    type = "EF00";
    content = {
      type = "filesystem";
      format = "vfat";
      mountpoint = "/boot";
      mountOptions = [ "umask=0077" ];
    };
  };
  mkSwap = { size ? "16G", priority ? 200 }: {
    inherit size priority;
    content.type = "swap";
  };
in { inherit mkBoot mkSwap; }
