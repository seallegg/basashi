{
  cfg = {
    core = {
      username = "seal";
      amdgpu.enable = true;
      git.name = "SeallEgg";
      git.email = "seallegg@gmail.com";
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
      swaync.enable = true;
      flatpak.enable = true;
    };
  };
}
