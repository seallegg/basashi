{
  security.sudo = {
    enable = true;
    execWheelOnly = true;
    extraConfig = ''
      Defaults lecture=never
      # Password entry timeout
      Defaults passwd_timeout=0
      # Increase timeout to 10 minutes
      Defaults timestamp_timeout=10
      # Shared timeout
      Defaults timestamp_type=global
    '';
  };
}
