{
  i18n = {
    defaultLocale = "en_DK.UTF-8";
    extraLocales = "all"; # why not?
    extraLocaleSettings = {
      LC_MONETARY = "pt_BR.UTF-8";
    };
  };
  time.timeZone = "America/Sao_Paulo";
  services.xserver.xkb = {
    layout = "us";
    variant = "intl";
  };
}
