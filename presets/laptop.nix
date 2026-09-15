# laptop extras to be used on top of the desktop preset
{
  basashi = {
    # hibernation needs to be set manually and should be enabled on these hosts
    services.powersaving.enable = true;
  };

  services.libinput.enable = true; # touchpad
  # fix keyboards/touchpads not working if touched during boot
  # (resets the PS/2 controller)
  boot.kernelParams = [ "i8042.reset" ];
}
