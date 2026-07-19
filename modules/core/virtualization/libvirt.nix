{ config, lib, ... }:
let cfg = config.basashi.core.virtualization.libvirt;
in {
  options.basashi.core.virtualization.libvirt = {
    enable = lib.mkEnableOption "libvirt, virt-manager and associated utilities";
  };

  config = lib.mkIf cfg.enable {
    # dedup identical pages across concurrent guests; free win with several vms
    hardware.ksm.enable = true;

    # evil british spelling
    virtualisation.libvirtd = {
      enable = true;
      qemu.swtpm.enable = true; # emulated tpm
    };
    programs.virt-manager.enable = true;
    users.users.${config.basashi.core.username}.extraGroups = [ "libvirtd" ];
  };
}
