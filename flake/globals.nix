# substituters, modules from inputs and other vital, generally flake-relevant config
#
# tuning that applies more to the nix cli or associated utilities is in modules/core/nix-utils.nix
{ inputs }:
let
  inherit (inputs.nixpkgs) lib;

  # tack adds __functor to the inputs which has to be filtered
  flakeInputs = lib.filterAttrs (n: _: n != "__functor") inputs;
  nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;

  # url = key
  substituters = {
    "https://nix-community.cachix.org" =
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
    "https://cache.nixos-cuda.org" =
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M=";
    "https://niri.cachix.org" =
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964=";
    "https://attic.xuyh0120.win/lantian" =
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=";
  };
in
[
  inputs.self.nixosModules.default
  inputs.disko.nixosModules.disko
  inputs.openlogi.nixosModules.default
  inputs.nixos-core.nixosModules.default
  ./bootstrapping.nix

  {
    nixpkgs = {
      config.allowUnfree = true;

      overlays = with inputs; [
        cachyos-kernel.overlays.default
        qt6ct-kde.overlays.default

        # vmTools now demands the kernel arg carry a .target or an explicit kernelImage
        # but disko still hands it an aggregateModules tree, so I can't build disko VMs
        # drop this once disko fixes its shit
        (final: prev: {
          vmTools = prev.vmTools.override { kernelImage = final.linux.target; };
        })
      ];
    };
    nix = {
      channel.enable = false;
      registry = builtins.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
      inherit nixPath;
      settings = {
        experimental-features = [ "nix-command" "flakes" ];
        allow-import-from-derivation = false;

        nix-path = nixPath;
        flake-registry = "";

        extra-substituters = builtins.attrNames substituters;
        extra-trusted-public-keys = builtins.attrValues substituters;
      };
    };
    programs.tack.enable = true;
  }
]
