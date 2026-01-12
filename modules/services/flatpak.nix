{
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.cfg.services.flatpak;
in {
  options.cfg.services.flatpak.enable = mkEnableOption "Flatpak";
  config = mkIf cfg.enable {
    services.flatpak.enable = true;
  };
}
