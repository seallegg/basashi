{
  config,
  lib,
  ...
}: let
  cfg = config.cfg.services.avahi;
in {
  options.cfg.services.avahi = {
    enable = lib.mkEnableOption "Avahi mDNS/DNS-SD discovery";
  };

  config = lib.mkIf cfg.enable {
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
        userServices = true;
      };
    };
  };
}
