{ config, ... }:

let
  btrfsMountOptions = [
    "noatime"
    "compress=zstd"
  ];

  # TODO: receive the two below variables as input from another file, make this a module
  # AKA don't hard-code...
  fsDevices = {
    efiPartitionUuid = "/dev/disk/by-partuuid/XXX";
    swap.unlockedUuid = "/dev/disk/by-partuuid/XXX";
    root.unlockedUuid = "/dev/disk/by-partuuid/XXX";
  };
  btrfsDevices = {
    "/" = { subvol = "@"; neededForBoot = true; };
    "/containercow" = { subvol = "@containercow"; };
    "/home" = { subvol = "@home"; };
    "/nix" = { subvol = "@nix"; };
    "/persist" = { subvol = "@persist"; neededForBoot = true; };
    "/var/log" = { subvol = "@log"; neededForBoot = true; };
  };
in {
  # TODO: Decide if this block should live here or get moved somewhere else
  # it is necessary for this to compile at time of this commit.
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/efi";
    };
    grub = {
      enable = true;
      device = "nodev";
      version = 2;
      efiSupport = true;
      enableCryptodisk = true;
    };
  };

  fileSystems = builtins.mapAttrs (
    mountPoint: btrfsDevice: {
      device = fsDevices.root.unlockedUuid;
      fsType = "btrfs";
      options = [ "subvol=${btrfsDevice.subvol}" ] ++ btrfsMountOptions;
    } // removeAttrs btrfsDevice [ "subvol" ]
  ) btrfsDevices // {
    "/efi" = {
      device = fsDevices.efiPartitionUuid;
      fsType = "vfat";
    };
  };

  swapDevices = [ { device = fsDevices.swap.unlockedUuid; } ];
}
