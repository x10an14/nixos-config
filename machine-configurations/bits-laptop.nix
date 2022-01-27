{config, lib, ...}:
{
  imports = [
    ../base/common/btrfs-devices.nix
    ../base/non-iso/initrd-ssh.nix
    ../base/non-iso/erase-your-darlings.nix
    ../base/non-iso/systemd-boot.nix
  ];

  # Machine unique software config
  networking = {
    hostName = "bits-laptop";
    interfaces = {
      enp0s31f6.useDHCP = true;
    };
  };

  # Allow SSH connections during boot to utilize ethernet network card
  boot.initrd.kernelModules = [ "e1000e" ];

  # Machine unique hardware config
  boot.kernelModules = [ "kvm-intel" ];
  hardware.video.hidpi.enable = lib.mkDefault true;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  btrfsDevices = {
    enable = true;
    efiPartitionDeviceId = "/dev/disk/by-partuuid/47d45141-6ab7-4121-b841-9989c1a72200";
    swap = {
      unlockedDeviceId = "/dev/disk/by-label/CRYPTSWAP";
      lockedDeviceId = "/dev/disk/by-partuuid/72e1590d-68b0-41cf-8f7c-afe0324a089d";
    };
    root = {
      unlockedDeviceId = "/dev/disk/by-label/CRYPTROOT";
      lockedDeviceId = "/dev/disk/by-partuuid/cd4eec94-04ab-4b1c-a3ce-f881c664f701";
    };
  };
}
