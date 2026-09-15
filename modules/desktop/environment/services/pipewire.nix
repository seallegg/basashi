{ config, lib, pkgs, ... }:
let
  cfg = config.basashi.services.pipewire;

  # front headphone jack detection is broken on columbia so id rather just not have it since I don't use other speakers
  # it's awful
  noJack = pkgs.runCommand "alsa-ucm-conf-alc4080-nojack-${pkgs.alsa-ucm-conf.version}" { } ''
    cp -r ${pkgs.alsa-ucm-conf}/share/alsa/ucm2 $out
    chmod -R u+w $out
    sed -i '/JackControl "''${var:HeadphonesJack}"/d' "$out/USB-Audio/Realtek/ALC4080-HiFi.conf"
  '';
in
{
  options.basashi.services.pipewire = {
    enable = lib.mkEnableOption "pipewire and associate utilities";
    noJackDetectAlc4080 =
      lib.mkEnableOption "disable front headphone jack detection on alc4080";
  };

  config = lib.mkIf cfg.enable {
    services.pipewire = {
      enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };
    environment.systemPackages = with pkgs; [ lxqt.pavucontrol-qt ];
    hj.xdg.config.files."pulse/client.conf".text = ''
      cookie-file = /home/youruser/.config/pulse/cookie
    '';

    systemd.user.services = lib.mkIf cfg.noJackDetectAlc4080 {
      pipewire.environment.ALSA_CONFIG_UCM2 = "${noJack}";
      wireplumber.environment.ALSA_CONFIG_UCM2 = "${noJack}";
    };
  };
}
