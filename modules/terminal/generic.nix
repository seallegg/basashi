{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    micro
    neovim
    fastfetch
    btop
  ];
}
