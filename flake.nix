{
  description = "basashi, a dendritic NixOS configuration";
  outputs = inputs @ {
    self,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];
      imports = [./imports.nix];
    };

  inputs = {
    # core
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    haumea.url = "github:nix-community/haumea";
    haumea.inputs.nixpkgs.follows = "nixpkgs";

    hjem.url = "github:feel-co/hjem";
    hjem.inputs.nixpkgs.follows = "nixpkgs";

    hjem-rum.url = "github:snugnug/hjem-rum";
    hjem-rum.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    nixdg-ninja.url = "github:notashelf/nixdg-ninja";
    nixdg-ninja.inputs.nixpkgs.follows = "nixpkgs";

    # other
    cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel";

    niri.url = "github:sodiboo/niri-flake";
    niri.inputs.nixpkgs.follows = "nixpkgs";

    helium.url = "github:schembriaiden/helium-browser-nix-flake";
    helium.inputs.nixpkgs.follows = "nixpkgs";

    millennium.url = "github:SteamClientHomebrew/Millennium?dir=packages/nix";
    millennium.inputs.nixpkgs.follows = "nixpkgs";

    qt6ct-kde.url = "github:SeallEgg/qt6ct-kde-flake";
    qt6ct-kde.inputs.nixpkgs.follows = "nixpkgs";

    apple-fonts.url = "github:SeallEgg/apple-fonts-flake";

    mullvad-declarative.url = "github:Daaboulex/mullvad-vpn-nix";
    mullvad-declarative.inputs.nixpkgs.follows = "nixpkgs";
  };
}
