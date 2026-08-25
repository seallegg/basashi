{ config, lib, ... }: {
  options.basashi.services.g502.enable = lib.mkEnableOption "g502";
  config = lib.mkIf config.basashi.services.g502.enable {
    programs.openlogi = {
      enable = true;
      launchAtLogin = true;
    };
    services.input-remapper = {
      enable = true;
      enableUdevRules = true;
    };
  };
}
