{
  cfg = {
    core = {
      kernel = "latest";
      username = "seal";
      amdgpu.enable = true;
      git.name = "SeallEgg";
      git.email = "seallegg@gmail.com";
    };

    desktop = {
      environment = {
        niri.enable = true;
        rofi.enable = true;
      };
      apps = {
        gaming.enable = true;
      };
    };

    services = {
      plymouth.enable = true;
      networkmanager.enable = true;
      powersaving.enable = true;
      greetd.enable = true;
      swww.enable = true;
      swaync.enable = true;
      automounting.enable = true;
    };
  };
}
