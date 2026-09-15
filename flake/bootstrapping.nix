# clones the config repo on activation and points every tool that needs the config dir
{ config, lib, pkgs, ... }:
let
  inherit (config.basashi.core) configDir username;
  repoUrl = "https://github.com/seallegg/basashi.git";

  # sudo is not included in PATH by default in activation so we use this instead
  asUser = "${pkgs.util-linux}/bin/runuser -u ${username} --";

  # named script so zed's nix injections give it bash highlighting (test)
  script = ''
    mkdir -p "${configDir}"
    chown ${username}:users "${configDir}"

    if [ ! -d "${configDir}/.git" ]; then
      echo "basashi: bootstrapping config repo at ${configDir}..."
      if [ -n "$(ls -A "${configDir}")" ]; then
         ${asUser} ${pkgs.git}/bin/git -C "${configDir}" init
         ${asUser} ${pkgs.git}/bin/git -C "${configDir}" remote add origin "${repoUrl}"
      else
         ${asUser} ${pkgs.git}/bin/git clone "${repoUrl}" "${configDir}"
      fi
    fi
  '';
in
{
  config = {
    environment.variables.FLAKE = configDir;
    programs.nh.flake = configDir;

    system.activationScripts.setupConfigRepo = lib.stringAfter [ "users" ] script;
  };
}
