{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
in {
  options.cfg.services.powersaving.enable = lib.mkEnableOption "power saving optimizations";
  config = mkIf config.cfg.services.powersaving.enable {
    networking.networkmanager.wifi.powersave = mkIf config.cfg.services.networkmanager.enable true;
    #powerManagement.powertop.enable = true;
  };
}
