{
  basashi = {
    core = {
      username = "seal";
      virtualization.guest = {
        enable = true;
        sharedDirectory = "/home/seal";
      };
      swap = {
        file.enable = false;
        zram.enable = true;
      };
    };

    terminal = {
      fish.enable = true;
      git.name = "seallegg";
      git.email = "seallegg@pm.me";
    };
  };
}
