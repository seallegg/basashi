{
  config,
  dotfiles,
  lib,
  pkgs,
  ...
}: {
  options.cfg.desktop.environment.matugen.enable = lib.mkEnableOption "matugen";

  config = lib.mkIf config.cfg.desktop.environment.matugen.enable {
    hj = {
      packages = with pkgs; [
        matugen
      ];
      xdg.config.files = {
        "matugen/config.toml" = {
          generator = lib.generators.toINI {};
          value = {
            "config.wallpaper" = {
              command = ''"awww img {{ image }}"'';
              set = "true";
            };
            "templates.qt" = {
              input_path = "'~/.config/matugen/templates/Darkly.template'";
              output_path = "'~/.local/share/color-schemes/Darkly.colors'";
            };
            "templates.rofi" = {
              input_path = "'~/.config/matugen/templates/rofi.template'";
              output_path = "'~/.config/rofi/colors.rasi'";
            };
          };
        };

        "matugen/templates/Darkly.template".text = builtins.readFile "${dotfiles}/matugen/Darkly.template";
        "matugen/templates/rofi.template".text = builtins.readFile "${dotfiles}/matugen/rofi.template";
      };
    };
  };
}
