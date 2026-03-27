{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
in {
  options.cfg.services.powersaving.enable = lib.mkEnableOption "power saving optimizations";
  config = mkIf config.cfg.services.powersaving.enable {
    networking.networkmanager.wifi.powersave = config.cfg.services.networking.networkmanager.enable;
    #powerManagement.powertop.enable = true;
  };
}
