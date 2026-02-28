{
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.cfg.services.powersaving;
in {
  options.cfg.services.powersaving.enable = mkEnableOption "power saving optimizations";
  config = mkIf cfg.enable {
    networking.networkmanager.wifi.powersave = mkIf config.cfg.services.networkmanager.enable true;
    #powerManagement.powertop.enable = true;
  };
}
