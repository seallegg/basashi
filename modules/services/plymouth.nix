{
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.cfg.services.plymouth;
in {
  options.cfg.services.plymouth.enable = mkEnableOption "Plymouth";
  config = mkIf cfg.enable {
    boot = {
      plymouth = {
        enable = true;
        theme = "bgrt";
      };
      consoleLogLevel = 3;
      kernelParams = ["quiet" "udev.log_level=3" "systemd.show_status=auto"];
    };
  };
}
