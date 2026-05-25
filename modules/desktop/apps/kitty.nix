{ config, lib, pkgs, ... }:
let cfg = config.basashi.desktop.environment;
in {
  config = lib.mkIf cfg.niri.enable or cfg.plasma.enable {
    hj = {
      packages = [ pkgs.kitty ];
      xdg.config.files."kitty/kitty.conf".text = ''
        allow_remote_control yes
        shell_integration zsh

        enable_audio_bell yes
        visual_bell_duration 1 ease-out
        window_alert_on_bell yes

        cursor_shape beam
        cursor_trail 1
        cursor_trail_start_threshold 0

        window_margin_width 4
        font size 12

        background_opacity 0.85
        include colors.conf
      '';
    };
  };
}
