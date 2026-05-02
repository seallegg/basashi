# such a stupid file name
{
  inputs,
  lib,
  ...
}: let
  inherit (builtins) mapAttrs;
  nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") inputs;
in {
  config = {
    nix = {
      channel.enable = false;
      registry = mapAttrs (_: flake: {inherit flake;}) inputs;

      inherit nixPath;

      settings = {
        nix-path = nixPath;
        flake-registry = "";
        experimental-features = ["nix-command" "flakes"];

        allow-import-from-derivation = false;
        auto-optimise-store = true;
        use-xdg-base-directories = true;
        extra-sandbox-paths = ["/var/cache/ccache"];
        download-buffer-size = 1024 * 1024 * 1024;
        http-connections = 50;
        allowed-users = ["@wheel"];
        trusted-users = ["@wheel"];

        accept-flake-config = true;
        extra-substituters = [
          "https://nix-community.cachix.org"
          "https://cache.nixos-cuda.org"
        ];
        extra-trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
        ];
      };
    };

    programs.ccache = {
      enable = true;
      cacheDir = "/var/cache/ccache";
    };

    nixpkgs.config.allowUnfree = true;

    programs.nh = {
      enable = true;
      clean = {
        enable = true;
        dates = "monthly";
        extraArgs = "--keep 10";
      };
    };

    documentation.nixos.enable = false;
  };
}
