{config, ...}:
{
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/efi";
    };
    grub.enable = false;
    systemd-boot = {
      enable = true;
      editor = false;
      configurationLimit = 14;
      memtest86.enable = true;
    };
  };
}
