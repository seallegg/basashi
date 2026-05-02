{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkOption types;
  cfg = config.basashi.services.hibernation;
in {
  options.basashi.services.hibernation = {
    enable = mkEnableOption "hibernation support";
    resumeDevice = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "The device to resume from.";
    };
    resumeOffset = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "The offset of a swapfile to be used for hibernation. Do not set this if you use a dedicated partition.";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.resumeDevice != null;
        message = "basashi.services.hibernation.resumeDevice must be set if hibernation is enabled.";
      }
      {
        assertion = (lib.hasInfix "/" (cfg.resumeDevice or "")) -> (cfg.resumeOffset != null);
        message = "basashi.services.hibernation.resumeOffset must be set if resumeDevice is a path to a swapfile.";
      }
    ];

    boot = {
      resumeDevice = cfg.resumeDevice;
      kernelParams = mkIf (cfg.resumeOffset != null) ["resume_offset=${cfg.resumeOffset}"];
    };

    systemd.sleep.settings.Sleep = {
      AllowHibernation = "yes";
      AllowHybridSleep = "yes";
      AllowSuspendThenHibernate = "yes";
      HibernateDelaySec = "30min";
    };
    services.logind.settings.Login = {
      HandlePowerKey = "hibernate";
      HandleLidSwitch = "suspend-then-hibernate";
    };
  };
}
