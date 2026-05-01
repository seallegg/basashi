{
  config,
  lib,
  pkgs,
  ...
}: {
  options.basashi.services.g502.enable = lib.mkEnableOption "g502";
  config = lib.mkIf config.basashi.services.g502.enable {
    hardware.logitech.wireless = {
      enable = true;
      enableGraphical = true;
    };
    services.input-remapper = {
      enable = true;
      enableUdevRules = true;
    };
    systemd.user.services.solaar = {
      enable = true;
      description = "Solaar autostart";
      after = ["graphical-session.target"];
      wantedBy = ["graphical-session.target"];
      before = ["input-remapper.service"];
      serviceConfig = {
        ExecStart = "${pkgs.solaar}/bin/solaar -w hide";
        ExecStartPost = "input-remapper-control --command autoload";
        Type = "simple";
      };
    };
  };
}
