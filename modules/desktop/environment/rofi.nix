{
  config,
  lib,
  pkgs,
  dotfiles,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.cfg.desktop.environment.rofi;
in {
  options.cfg.desktop.environment.rofi = {
    enable = mkEnableOption "rofi";
  };

  config = mkIf cfg.enable {
    hj = {
      packages = [pkgs.rofi];
      xdg.config.files = {
        "rofi/config.rasi".text = dotfiles.rofi "config.rasi";
        "rofi/theme.rasi".text = dotfiles.rofi "theme.rasi";
      };
    };
  };
}
