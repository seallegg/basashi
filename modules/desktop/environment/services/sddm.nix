{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf;
  cfg = config.basashi.services.sddm;
  monitors = config.basashi.core.hardware.monitors;
  xkb = config.services.xserver.xkb;

  primary = lib.head monitors; # first listed monitor, same convention niri uses

  # weston kiosk only ever paints the greeter on a single output, and it doesn't
  # reliably pick the right one. switching the rest off pins it to the main display.
  outputSections = lib.concatMapStrings (m: ''

    [output]
    name=${m.name}
    mode=${if m.name == primary.name then m.res else "off"}
  '') monitors;

  westonIni = pkgs.writeText "weston.ini" (''
    [shell]
    background-color=0xff000000

    [libinput]
    enable-tap=${lib.boolToString config.services.libinput.touchpad.tapping}

    [keyboard]
    keymap_layout=${xkb.layout}
    keymap_variant=${xkb.variant}
    keymap_options=${xkb.options}
  '' + lib.optionalString (monitors != [ ]) outputSections);
in {
  options.basashi.services.sddm.enable = lib.mkEnableOption "SDDM";

  config = mkIf cfg.enable {
    services.displayManager.sddm = {
      enable = true;
      theme = "${pkgs.elegant-sddm}/share/sddm/themes/Elegant";
      extraPackages = with pkgs.kdePackages; [ qtmultimedia qtsvg qtvirtualkeyboard qt5compat ];
      wayland = {
        enable = true;
        compositorCommand =
          mkIf (monitors != [ ]) "${lib.getExe pkgs.weston} --shell=kiosk -c ${westonIni}";
      };
    };
    environment.systemPackages = [ pkgs.elegant-sddm ];
  };
}
