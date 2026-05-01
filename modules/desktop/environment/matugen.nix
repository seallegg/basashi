{
  config,
  dotfiles,
  lib,
  pkgs,
  ...
}: {
  options.basashi.desktop.environment.matugen.enable = lib.mkEnableOption "matugen";

  config = lib.mkIf config.basashi.desktop.environment.matugen.enable {
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
            "templates.kitty" = {
              input_path = "'~/.config/matugen/templates/kitty.template'";
              output_path = "'~/.config/kitty/colors.conf'";
              post_hook = "'kill -SIGUSR1 $KITTY_PID'";
            };
            "templates.niri" = {
              input_path = "'~/.config/matugen/templates/niri.template'";
              output_path = "'~/.config/niri/colors.kdl'";
              post_hook = "'niri msg action load-config-file'";
            };
          };
        };

        "matugen/templates/Darkly.template".text = builtins.readFile "${dotfiles}/matugen/Darkly.template";
        "matugen/templates/rofi.template".text = builtins.readFile "${dotfiles}/matugen/rofi.template";
        "matugen/templates/kitty.template".text = builtins.readFile "${dotfiles}/matugen/kitty.template";
        "matugen/templates/niri.template".text = builtins.readFile "${dotfiles}/matugen/niri.template";
      };
    };
  };
}
