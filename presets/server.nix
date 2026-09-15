# headless host defaults
{
  basashi = {
    core.swap.zram = {
      enable = true;
      algorithm = "zstd";
    };
    services.avahi.enable = true;
  };
}
