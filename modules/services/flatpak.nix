{
  config,
  lib,
  ...
}: {
  options.basashi.services.flatpak.enable = lib.mkEnableOption "Flatpak";
  config = lib.mkIf config.basashi.services.flatpak.enable {
    services.flatpak.enable = true;
  };
}
