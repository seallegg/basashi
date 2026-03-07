{
  config,
  lib,
  ...
}: {
  options.cfg.services.plymouth.enable = lib.mkEnableOption "Plymouth";
  config = lib.mkIf config.cfg.services.plymouth.enable {
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
