{ config, lib, ... }:

# To allow usage of `types.X`:
with lib;

let
  cfg = config.btrfsDevices;
  btrfsMountOptions = [
    "defaults"
    "noatime"
    "compress=zstd"
  ];

  # Stolen from github:nixos/nixpgks/nixos-21.11:nixos/modules/tasks/filesystems.nix:
  addCheckDesc = desc: elemType: check: types.addCheck elemType check
    // { description = "${elemType.description} (with check: ${desc})"; };
  isNonEmpty = s: (builtins.match "[ \t\n]*" s) == null;
  nonEmptyStr = addCheckDesc "non-empty" types.str isNonEmpty;
  nonEmptyWithoutTrailingSlash = addCheckDesc "non-empty without trailing slash" types.str
    (s: isNonEmpty s && (builtins.match ".+/" s) == null);

  btrfsDeviceOpts = {name, config, ...}: {
    options = {
      mountPoint = mkOption {
        example = "/mnt/data";
        type = nonEmptyWithoutTrailingSlash;
      };
      device = mkOption {
        default = null;
        example = "/dev/disk/by-label/DISK";
        type = types.nullOr nonEmptyWithoutTrailingSlash;
      };
      neededForBoot = mkOption {
        example = true;
        default = false;
        type = types.bool;
      };
      subvol = mkOption {
        default = null;
        example = "@subvol";
        type = nonEmptyStr;
      };
    };
    config.mountPoint = mkDefault name;
  };
in {
  options = {
    btrfsDevices = {
      enable = mkEnableOption "btrfsDevices";
      efiPartitionDeviceId = mkOption {
        default = null;
        type = types.path;
        example = /dev/disk/by-partuuid/X;
      };
      swap = {
        unlockedDeviceId = mkOption {
          default = null;
          type = types.path;
          example = /dev/disk/by-partuuid/X;
        };
        lockedDeviceId = mkOption {
          default = null;
          type = types.path;
          example = /dev/disk/by-partuuid/X;
        };
      };
      root = {
        lockedDeviceId = mkOption {
          default = null;
          type = types.path;
          example = /dev/disk/by-partuuid/X;
        };
        unlockedDeviceId = mkOption {
          default = null;
          type = types.path;
          example = /dev/disk/by-partuuid/X;
        };
      };
      subvolumes = mkOption {
        type = types.attrsOf (types.submodule [ btrfsDeviceOpts ]);
        default = {
          "/" = { subvol = "@"; neededForBoot = true; };
          "/containercow" = { subvol = "@containercow"; };
          "/home" = { subvol = "@home"; };
          "/nix" = { subvol = "@nix"; };
          "/persist" = { subvol = "@persist"; neededForBoot = true; };
          "/var/log" = { subvol = "@log"; };
        };
        example = literalExpression ''
          {
            "/" = { subvol = "@"; };
            "/containercow" = { subvol = "@containercow"; };
            "/home" = { subvol = "@home"; };
            "/nix" = { subvol = "@nix"; };
            "/persist" = { subvol = "@persist"; neededForBoot = true; };
            "/var/log" = { subvol = "@log"; };
            "/mnt/meh" = { subvol = "@meh"; device = "/dev/disk/by-uuid/FOO"; neededForBoot = true; };
          };
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    fileSystems = builtins.mapAttrs (
      mountPoint: btrfsDevice:
        removeAttrs btrfsDevice [ "subvol" ] // {
          device = if btrfsDevice.device != null then btrfsDevice.device else cfg.root.unlockedDeviceId;
          fsType = "btrfs";
          options = [ "subvol=${btrfsDevice.subvol}" ] ++ btrfsMountOptions;
        }
    ) cfg.subvolumes // {
      "/efi" = {
        device = cfg.efiPartitionDeviceId;
        fsType = "vfat";
      };
    };

    swapDevices = [ { device = cfg.swap.unlockedDeviceId; } ];
  };
}
