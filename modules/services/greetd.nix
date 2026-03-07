{
  config,
  lib,
  pkgs,
  ...
}: {
  options.cfg.services.greetd.enable = lib.mkEnableOption "greetd";
  config = lib.mkIf config.cfg.services.greetd.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet";
          user = "${config.cfg.core.username}";
        };
      };
    };
  };
}
