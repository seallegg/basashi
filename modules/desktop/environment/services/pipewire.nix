{ config, lib, pkgs, ... }: {
  options.basashi.services.pipewire.enable = lib.mkEnableOption "pipewire and associate utilities";
  config = lib.mkIf config.basashi.services.pipewire.enable {
    services.pipewire = {
      enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };
    environment.systemPackages = with pkgs; [ lxqt.pavucontrol-qt ];
    hj.xdg.config.files."pulse/client.conf".text = ''
      cookie-file = /home/youruser/.config/pulse/cookie
    '';
  };
}
