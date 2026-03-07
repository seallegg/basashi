{
  config,
  lib,
  ...
}: {
  options.cfg.services.flatpak.enable = lib.mkEnableOption "Flatpak";
  config = lib.mkIf config.cfg.services.flatpak.enable {
    services.flatpak.enable = true;
  };
}
