{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.cfg.desktop.apps.thunderbird;
in {
  options.cfg.desktop.apps.thunderbird.enable = mkEnableOption "rofi";
  config = mkIf cfg.enable {
    programs.thunderbird = {
      enable = true;
    };
    services.protonmail-bridge.enable = true;
  };
}
