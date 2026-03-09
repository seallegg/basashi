{
  cfg = {
    core = {
      kernel = "custom";
      username = "seal";
      nvidia.enable = true;
      git.name = "SeallEgg";
      git.email = "seallegg@gmail.com";
      forceCompiledPkgs = {
        enable = true;
        pkgs = [
          "nix"
          "gcc"
        ];
      };
    };

    desktop = {
      environment = {
        niri.enable = true;
        rofi.enable = true;
      };
      apps = {
        gaming.enable = true;
        thunderbird.enable = true;
      };
    };

    services = {
      plymouth.enable = true;
      networkmanager.enable = true;
      greetd.enable = true;
      swww.enable = true;
      swaync.enable = true;
      flatpak.enable = true;
      automounting.enable = true;
      idevices.enable = true;
      g502.enable = true;
    };
  };
}
