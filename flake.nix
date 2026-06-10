{
  description = "basashi, a synaptic NixOS configuration";
  outputs = inputs: import ./imports.nix { inherit inputs; };

  inputs = {
    # core
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    hjem.url = "github:feel-co/hjem";
    hjem.inputs.nixpkgs.follows = "nixpkgs";

    hjem-rum.url = "github:snugnug/hjem-rum";
    hjem-rum.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # other
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    chaotic.inputs.nixpkgs.follows = "nixpkgs";

    cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel";
    # this CANNOT follow our nixpkgs

    nixdg-ninja.url = "github:notashelf/nixdg-ninja";
    nixdg-ninja.inputs.nixpkgs.follows = "nixpkgs";

    helium.url = "github:schembriaiden/helium-browser-nix-flake";
    helium.inputs.nixpkgs.follows = "nixpkgs";

    millennium.url = "github:SteamClientHomebrew/Millennium/next?dir=packages/nix";
    millennium.inputs.nixpkgs.follows = "nixpkgs";

    headroom.url = "github:manic-systems/headroom";
    headroom.inputs.nixpkgs.follows = "nixpkgs";

    qt6ct-kde.url = "github:SeallEgg/qt6ct-kde-flake";
    qt6ct-kde.inputs.nixpkgs.follows = "nixpkgs";

    apple-fonts.url = "github:SeallEgg/apple-fonts-flake";
    apple-fonts.inputs.nixpkgs.follows = "nixpkgs";

    #mullvad-declarative.url = "github:Daaboulex/mullvad-vpn-nix";
    #mullvad-declarative.inputs.nixpkgs.follows = "nixpkgs";
  };
}
