{
  config,
  lib,
  pkgs,
  inputs,
  hostConfig,
  dotfiles,
  ...
}: let
  inherit (lib) mkEnableOption mkIf imap0;
  cfg = config.cfg.desktop.environment.niri;
  monitorConfig =
    if hostConfig.monitors != null
    then
      lib.concatStringsSep "\n" (imap0 (i: m: ''
          output "${m.name}" {
              mode "${m.res}"
              position x=${toString m.pos.x} y=${toString m.pos.y}
              scale ${toString m.scale}
              ${
            if i == 0
            then "focus-at-startup" # The first monitor is set as main
            else ""
          }
          }
        '')
        hostConfig.monitors)
    else "";
in {
  options.cfg.desktop.environment.niri = {
    enable = mkEnableOption "niri";
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [inputs.niri.overlays.niri];
    programs.niri = {
      enable = true;
      package = pkgs.niri-unstable;
    };
    hj.rum.desktops.niri = {
      enable = true;
      package = pkgs.niri-unstable;
      config = monitorConfig + dotfiles.niri "config.kdl";
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
