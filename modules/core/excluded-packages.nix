{ lib, pkgs, ... }: {
  programs.nano.enable = false;
  environment = {
    systemPackages = [ pkgs.micro ];
    variables.EDITOR = "micro";
    defaultPackages = [ ];
  };
  documentation.doc.enable = lib.mkForce false;
}
