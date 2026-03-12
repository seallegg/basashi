{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  outputConfig =
    lib.ConcatMapStrings (m: ''
      [output]
      name=${m.name}
      mode=${m.res}
    '')
    config.cfg.hardware.monitors;
  westonIni =
    ''
      [keyboard]
      keymap_layout=${config.services.xserver.xkb.layout}
    ''
    + outputConfig;
in {
  options.cfg.services.sddm.enable = lib.mkEnableOption "SDDM";
  config = mkIf config.cfg.services.sddm.enable {
    services.displayManager.sddm = {
      enable = true;
      wayland = {
        enable = true;
        #   compositorCommand =
        #     mkIf config.cfg.desktop.environment.plasma.enable
        #     "${lib.getExe pkgs.weston} --shell=kiosk -c ${westonIni}";
      };
    };
    # systemd.services."display-manager" = mkIf config.cfg.services.plymouth.enable {
    #   conflicts = ["plymouth-quit.service"];
    #   preStart = "${pkgs.plymouth}/bin/plymouth deactivate";
    #   script = "/run/current-system/sw/bin/sddm";
    #   postStart = "/bin/sh -c 'sleep 5 && ${pkgs.plymouth}/bin/plymouth quit --retain-splash'";
    #   enable = true;
    # };
  };
}
