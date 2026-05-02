{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.basashi.services.coolercontrol;
in {
  options.basashi.services.coolercontrol = {
    enable = lib.mkEnableOption "CoolerControl";
  };
  config = lib.mkIf cfg.enable {
    programs.coolercontrol.enable = true;
    environment.systemPackages = with pkgs; [
      lm_sensors
      liquidctl
    ];
  };
}
