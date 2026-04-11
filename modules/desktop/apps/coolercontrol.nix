{
  config,
  lib,
  pkgs,
  ...
}: {
  options.cfg.desktop.apps.coolercontrol = {
    enable = lib.mkEnableOption "CoolerControl";
  };
  config = lib.mkIf config.cfg.desktop.apps.coolercontrol.enable {
    programs.coolercontrol.enable = true;
    environment.systemPackages = with pkgs; [
      lm_sensors
      liquidctl
    ];
  };
}
