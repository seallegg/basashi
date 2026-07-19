{ config, lib, pkgs, ... }:
let cfg = config.basashi.desktop.environment;
in {
  config = lib.mkIf cfg.niri.enable or cfg.plasma.enable {
    hj = {
      packages = [ pkgs.kitty ];
      xdg.config.files."kitty/kitty.conf".text = ''
        allow_remote_control socket-only
        # path socket instead of abstract: 0700 runtime dir gates who can connect.
        # kitty appends -PID to the name, so the real socket is kitty.sock-<pid>
        listen_on unix:''${XDG_RUNTIME_DIR}/kitty.sock

        enable_audio_bell yes
        visual_bell_duration 1 ease-out
        window_alert_on_bell yes

        cursor_shape beam
        cursor_trail 1
        cursor_trail_start_threshold 0

        window_margin_width 4
        font size 13

        background_opacity 0.85
        include colors.conf
      '';
    };
  };
}
