{
  config,
  dotfiles,
  lib,
  pkgs,
  ...
}: {
  options.cfg.desktop.environment.rofi = {
    enable = lib.mkEnableOption "rofi";
  };

  config = lib.mkIf config.cfg.desktop.environment.rofi.enable {
    hj = {
      packages = [pkgs.rofi];
      xdg.config.files = {
        "rofi/config.rasi".text = builtins.readFile "${dotfiles}/rofi/config.rasi";
        "rofi/theme.rasi".text = builtins.readFile "${dotfiles}/rofi/theme.rasi";
      };
    };
  };
}
