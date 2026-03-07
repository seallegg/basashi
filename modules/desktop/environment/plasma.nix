{
  config,
  lib,
  pkgs,
  ...
}: {
  options.cfg.desktop.environment.plasma = {
    enable = lib.mkEnableOption "KDE plasma";
  };

  config = lib.mkIf config.cfg.desktop.environment.plasma.enable {
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
