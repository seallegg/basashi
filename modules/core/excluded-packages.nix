{ lib, ... }:
let
in {
  environment.defaultPackages = lib.mkDefault [ ];
  programs.nano.enable = false;
}
