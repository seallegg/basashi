# host-building machinery; probably what you'd most expect to be in the flake
{ inputs }:
let
  inherit (inputs.nixpkgs) lib;
  inherit (lib) mkDefault;

  imported = import ./imports.nix { inherit inputs lib; };

  hosts = import ./loader.nix { inherit lib; } { src = ../hosts; };

  mkSystem = hostName: path:
    lib.nixosSystem {
      inherit (imported) specialArgs;
      modules = imported.globals ++ imported.presets.modulesFor path ++ [
        path
        imported.presets.option
        {
          networking.hostName = mkDefault hostName;
          nixpkgs.hostPlatform = mkDefault "x86_64-linux"; # too poor 4 arm
          system.stateVersion = mkDefault "25.11"; # prolly not a good idea. oh well.
        }
      ];
    };
in
{
  nixosModules = imported.modules.tree // {
    default = {
      imports = imported.modules.list;
      _module.args.dotfiles = imported.dotfiles.tree;
    };
  };
  nixosConfigurations = lib.mapAttrs mkSystem hosts.tree;
  formatter = lib.genAttrs [ "x86_64-linux" "aarch64-linux" ]
    (system: inputs.nixpkgs.legacyPackages.${system}.nixpkgs-fmt);
}
