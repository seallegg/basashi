{
  config,
  lib,
  ...
}: {
  options.cfg.desktop.apps.thunderbird.enable = lib.mkEnableOption "rofi";
  config = lib.mkIf config.cfg.desktop.apps.thunderbird.enable {
    programs.thunderbird = {
      enable = true;
    };
    services.protonmail-bridge.enable = true;
  };
}
