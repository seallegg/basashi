{
  system = "x86_64-linux";
  arch = "znver4";
  monitors = [
    {
      name = "DP-1";
      res = "2560x1440@170.001";
      pos = {
        x = 0;
        y = 0;
      };
      scale = 1;
    }
    {
      name = "HDMI-A-1";
      res = "3840x2160@60";
      pos = {
        x = 1920;
        y = 0;
      };
      scale = 1.5;
    }
  ];
}
