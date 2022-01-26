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
  fileSystems = builtins.ListToAttrs (
    builtins.mapAttrs (
      mountPoint: btrfsDevice: {
        name = mountPoint;
        value = {
          device = fsDevices.root.unlockedUuid;
          fsType = "btrfs";
          options = [ "subvol=${btrfsDevice.subvol}" ] ++ btrfsMountOptions;
        } // removeAttrs btrfsDevice [ "subvol" ];
      }
    )
  ) btrfsDevices // {
    "/efi" = {
      device = fsDevices.efiPartitionUuid;
      fsType = "vfat";
    };
  };

  swapDevices = [ { device = fsDevices.swap.unlockedUuid; } ];
}
