{
  self,
  inputs,
  pins,
  withSystem,
  lib,
  ...
}: let
  inherit (lib) genAttrs nixosSystem filterAttrs;
  inherit (builtins) attrNames readDir;

  # Filter readDir to only include directories
  dirs = filterAttrs (_: type: type == "directory") (readDir ./.);

  mkSystem = hostName: let
    hostConfig = import ./${hostName}/system.nix;
    system = hostConfig.system; # used for pre-selecting platforms using flake-parts
    arch = hostConfig.arch or null; # for optional tuning
    dotfiles = builtins.listToAttrs ( # this is unnecessary but it's nicer to look at imo :^)
      map (dir: {
        name = dir;
        value = file: builtins.readFile (self + "/dotfiles/${dir}/${file}");
      }) (builtins.attrNames (builtins.readDir (self + "/dotfiles")))
    );
  in
    withSystem system ({
      inputs',
      self',
      ...
    }:
      nixosSystem {
        specialArgs = {
          inherit self self' inputs inputs' hostName pins hostConfig dotfiles;
        };
        modules = [
          self.nixosModules.default # ${self}/modules directory as a nixosModule

          ./${hostName}
          {
            nixpkgs.hostPlatform = system;
            nix.settings.system-features =
              [
                "benchmark"
                "big-parallel"
                "kvm"
                "nixos-test"
              ]
              ++ (lib.lists.optional (hostConfig.arch != null) "gccarch-${arch}");
          }
        ];
      });
in {
  flake.nixosConfigurations = genAttrs (attrNames dirs) mkSystem;
}
