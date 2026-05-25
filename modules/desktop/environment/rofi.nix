{ config, dotfiles, lib, pkgs, ... }: {
  options.basashi.desktop.environment.rofi = { enable = lib.mkEnableOption "rofi"; };

  config = lib.mkIf config.basashi.desktop.environment.rofi.enable {
    hj = {
      packages = [ pkgs.rofi ];
      xdg.config.files = {
        "rofi/config.rasi".text = ''
          configuration {
            show-icons: true;
            display-drun:  "Rofi";
            require-input: true;
              timeout {
                  action: "kb-cancel";
                  delay:  0;
              }
              filebrowser {
                  directories-first: true;
                  sorting-method:    "name";
              }
          }
          @theme "./theme.rasi"
        '';
        "rofi/theme.rasi".text = dotfiles.rofi.theme;
      };
    };
  };
}
