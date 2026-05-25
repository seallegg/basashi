{ config, lib, ... }: {
  options.basashi.services.printing.enable = lib.mkEnableOption "Printing";
  config = lib.mkIf config.basashi.services.printing.enable { services.printing.enable = true; };
}
