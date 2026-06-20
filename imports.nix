{ inputs }:
let
  inherit (inputs.nixpkgs) lib;
  inherit (inputs.self) outputs;
  inherit (lib) hasSuffix isAttrs mkDefault;

  load = import ./utils/loader.nix { inherit lib; };

  modules = load {
    src = ./. + "/modules";
    fileFilter = name: type: hasSuffix ".nix" name;
  };

  hosts = load {
    src = ./. + "/hosts";
    fileFilter = name: type: hasSuffix ".nix" name;
  };

  dotfiles = load {
    src = ./. + "/dotfiles";
    mapper = name: path: builtins.readFile path;
  };

  mkSystem = hostName: path:
    lib.nixosSystem {
      specialArgs = {
        inherit (inputs) self;
        inherit inputs;
      };
      modules = [
        outputs.nixosModules.default
        inputs.chaotic.nixosModules.default
        inputs.headroom.nixosModules.default
        inputs.disko.nixosModules.disko
        path
        {
          nixpkgs.overlays = with inputs; [
            cachyos-kernel.overlays.default
            millennium.overlays.default
            qt6ct-kde.overlays.default
            #mullvad-declarative.overlays.default
          ];

          networking.hostName = mkDefault hostName;
          nixpkgs.hostPlatform = mkDefault "x86_64-linux";
          system.stateVersion = mkDefault "25.11";
        }
      ];
    };
in {
  nixosModules = modules.tree // {
    default = {
      imports = modules.list;
      _module.args.dotfiles = dotfiles.tree;
    };
  };
  nixosConfigurations =
    lib.mapAttrs (name: path: mkSystem name path) (lib.filterAttrs (n: v: !isAttrs v) hosts.tree);
  formatter = lib.genAttrs [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ]
    (system: inputs.nixpkgs.legacyPackages.${system}.nixfmt-classic);
}
