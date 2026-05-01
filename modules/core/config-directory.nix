{
  config,
  lib,
  pkgs,
  ...
}: let
  username = config.basashi.core.username;
  configDir = "/home/${username}/basashi";
in {
  environment.variables.FLAKE = configDir;
  programs.nh.flake = configDir;

  system.activationScripts.setupConfigRepo = lib.stringAfter ["users"] ''
    if [ ! -d "${configDir}" ]; then
      mkdir -p "${configDir}"
      chown ${username}:users "${configDir}"

      if [ ! -d "${configDir}/.git" ]; then
        sudo -u ${username} ${pkgs.git}/bin/git -C "${configDir}" init
        sudo -u ${username} ${pkgs.git}/bin/git -C "${configDir}" remote add origin "https://github.com/SeallEgg/basashi.git"
      fi
    fi
  '';
}
