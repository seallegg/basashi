{
  config,
  lib,
  pkgs,
  inputs,
  hostConfig,
  dotfiles,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.cfg.desktop.environment.niri;
  monitorConfig =
    lib.concatMapStringsSep "\n" (m: ''
      output "${m.name}" {
          mode "${m.res}"
          position x=${toString m.pos.x} y=${toString m.pos.y}
          scale ${toString m.scale}
      }
    '')
    hostConfig.monitors;
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
    };
    environment.systemPackages = with pkgs; [
      xwayland-satellite
    ];
  };
}
