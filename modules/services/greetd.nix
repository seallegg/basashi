{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.cfg.services.greetd;
in {
  options.cfg.services.greetd.enable = mkEnableOption "greetd";
  config = mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings = {
        defaultSession = {
          command = "${pkgs.niri}/bin/niri-session";
        };
      };
    };
  };
}
