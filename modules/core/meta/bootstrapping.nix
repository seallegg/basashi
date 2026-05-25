{ config, lib, pkgs, ... }:
let
  username = config.basashi.core.username;
  configDir = "/home/${username}/basashi";
  repoUrl = "https://github.com/SeallEgg/basashi.git";
in {
  config = {
    environment.variables.FLAKE = configDir;
    programs.nh.flake = configDir;

    system.activationScripts.setupConfigRepo = lib.stringAfter [ "users" ] ''
      mkdir -p "${configDir}"
      chown ${username}:users "${configDir}"

      if [ ! -d "${configDir}/.git" ]; then
        echo "basashi: bootstrapping config repo at ${configDir}..."
        if [ -n "$(ls -A "${configDir}")" ]; then
           sudo -u ${username} ${pkgs.git}/bin/git -C "${configDir}" init
           sudo -u ${username} ${pkgs.git}/bin/git -C "${configDir}" remote add origin "${repoUrl}"
        else
           sudo -u ${username} ${pkgs.git}/bin/git clone "${repoUrl}" "${configDir}"
        fi
      fi
    '';
  };
}
