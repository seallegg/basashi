{ config, inputs, lib, pkgs, ... }:
let
  inherit (lib.modules) mkAliasOptionModule;
  inherit (config.basashi.core) username;
in {
  options.basashi.core.username = lib.mkOption {
    type = lib.types.str;
    default = "user";
    description = "Sets the username for the system.";
  };
  imports =
    [ inputs.hjem.nixosModules.default (mkAliasOptionModule [ "hj" ] [ "hjem" "users" username ]) ];
  config = {
    users.users.${username} = {
      isNormalUser = true;
      initialPassword = "changeme";
      extraGroups = [ "wheel" "video" "input" ];
      uid = 1000;
    };
    hjem = {
      linker = inputs.hjem.packages.${pkgs.stdenv.hostPlatform.system}.smfh;
      clobberByDefault = true;
      users.${username} = { enable = true; };
      extraModules = [ inputs.hjem-rum.hjemModules.default ];
    };
  };
}
