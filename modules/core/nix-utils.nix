# stuff like the registry, nix-path, channels, caches, tack) is in flake/globals.nix
{
  nix.settings = {
    auto-optimise-store = true;
    use-xdg-base-directories = true;
    extra-sandbox-paths = [ "/var/cache/ccache" ];
    download-buffer-size = 1024 * 1024 * 1024;
    http-connections = 50;
    allowed-users = [ "@wheel" ];
    trusted-users = [ "@wheel" ];
  };

  programs = {
    ccache = {
      enable = true;
      cacheDir = "/var/cache/ccache";
    };

    nh = {
      enable = true;
      clean = {
        enable = true;
        dates = "monthly";
        extraArgs = "--keep 10";
      };
    };
  };
  system.nixos-core.enable = true;
  documentation.nixos.enable = false;
}
