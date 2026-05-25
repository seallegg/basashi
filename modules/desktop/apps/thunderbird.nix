{ config, lib, ... }: {
  options.basashi.desktop.apps.thunderbird.enable = lib.mkEnableOption "rofi";
  config = lib.mkIf config.basashi.desktop.apps.thunderbird.enable {
    programs.thunderbird = { enable = true; };
    services.protonmail-bridge.enable = true;
  };
}
