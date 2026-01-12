{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.cfg.desktop.environment.plasma;
in {
  options.cfg.desktop.environment.plasma = {
    enable = mkEnableOption "KDE plasma";
  };

  config = mkIf cfg.enable {
    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;
    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      plasma-browser-integration
      konsole
      elisa
      kwallet
      khelpcenter
    ];
  };
}
