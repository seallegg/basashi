{
  config,
  lib,
  ...
}: let
  cfg = config.basashi.core.locale;
in {
  options.basashi.core.locale = {
    defaultLocale = lib.mkOption {
      type = lib.types.str;
      default = "en_DK.UTF-8";
      description = "The default locale for the system.";
    };
    timeZone = lib.mkOption {
      type = lib.types.str;
      default = "America/Sao_Paulo";
      description = "The system timezone.";
    };
  };

  config = {
    i18n = {
      defaultLocale = cfg.defaultLocale;
      extraLocales = ["all"];
      extraLocaleSettings = {
        LC_MONETARY = "pt_BR.UTF-8";
      };
    };
    time.timeZone = cfg.timeZone;
    services.xserver.xkb = {
      layout = "us";
      variant = "intl";
    };
  };
}
