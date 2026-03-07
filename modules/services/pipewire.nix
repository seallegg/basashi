{pkgs, ...}: {
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };
  environment.systemPackages = with pkgs; [
    pavucontrol
  ];
  hj.xdg.config.files."pulse/client.conf".text = ''
    cookie-file = /home/youruser/.config/pulse/cookie
  '';
}
