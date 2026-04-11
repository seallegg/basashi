{
  config,
  dotfiles,
  inputs,
  lib,
  pkgs,
  ...
}: let
  monitorConfig =
    if config.cfg.hardware.monitors != []
    then
      lib.concatStringsSep "\n" (lib.imap0 (i: m: ''
          output "${m.name}" {
              mode "${m.res}"
              position x=${toString m.pos.x} y=${toString m.pos.y}
              scale ${toString m.scale}
              ${
            if i == 0
            then "focus-at-startup" # The first monitor is set as main
            else ""
          }
            ${
            if m.VRR
            then "variable-refresh-rate on-demand=true"
            else ""
          }
          }
        '')
        config.cfg.hardware.monitors)
    else "";
in {
  options.cfg.desktop.environment.niri = {
    enable = lib.mkEnableOption "niri";
  };

  config = lib.mkIf config.cfg.desktop.environment.niri.enable {
    nixpkgs.overlays = [inputs.niri.overlays.niri];
    programs.niri = {
      enable = true;
      package = pkgs.niri-unstable;
    };
    hj.rum.desktops.niri = {
      enable = true;
      package = pkgs.niri-unstable;
      config = monitorConfig + builtins.readFile "${dotfiles}/niri/config.kdl";
      extraVariables = {
        XDG_SESSION_TYPE = "wayland";
        XDG_CURRENT_DESKTOP = "niri";
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
      };
    };
    environment.systemPackages = with pkgs; [
      xwayland-satellite
      brightnessctl
      playerctl
    ];
  };
}
