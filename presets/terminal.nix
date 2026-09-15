# the shared shell bundle
{ pkgs, ... }:
{
  basashi.terminal = {
    fish.enable = true;
    git = {
      email = "seallegg@pm.me";
      name = "seallegg";
    };
    ohMyPosh.enable = true;
    rusty.enable = true;
  };
  environment.systemPackages = with pkgs; [ neovim fastfetch btop usbutils ];
}
