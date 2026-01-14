{
  cfg = {
    core = {
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
        plasma.enable = true;
        niri.enable = true;
        rofi.enable = true;
      };
      apps = {
        gaming.enable = true;
      };
    };

    services = {
      sddm.enable = true;
      swww.enable = true;
      flatpak.enable = true;
      idevices.enable = true;
    };
  };
}
