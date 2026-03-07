{
  config,
  lib,
  pkgs,
  ...
}: {
  options.cfg.services.g502.enable = lib.mkEnableOption "g502";
  config = lib.mkIf config.cfg.services.g502.enable {
    hardware.logitech.wireless.enable = true;
    hardware.logitech.wireless.enableGraphical = true; # Installs Solaar and udev rules
    environment.systemPackages = with pkgs; [
      input-remapper
      usbutils
    ];
  };
}
