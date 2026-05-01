{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.basashi.desktop.environment;
in {
  config = lib.mkIf (cfg.niri.enable or cfg.plasma.enable) {
    hj = {
      packages = with pkgs; [
        zed-editor
        gemini-cli
        alejandra
        nixd
      ];
    };
  };
}
