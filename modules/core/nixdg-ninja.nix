# aka MAKE /home TIDY AGAIN
{inputs, ...}: {
  imports = [inputs.nixdg-ninja.nixosModules.nixdg-ninja];
  programs.nixdg-ninja = {
    enable = true;
  };
}
