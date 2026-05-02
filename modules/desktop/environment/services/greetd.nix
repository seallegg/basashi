{
  config,
  lib,
  pkgs,
  ...
}: {
  options.basashi.services.greetd.enable = lib.mkEnableOption "greetd";
  config = lib.mkIf config.basashi.services.greetd.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet";
          user = "${config.basashi.core.username}";
        };
      };
    };
  };
}
