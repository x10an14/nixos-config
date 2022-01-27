{ config, lib, pkgs, ... }:
let
  corebin = "${pkgs.coreutils}/bin";
  mountbin = "${pkgs.mount}/bin";
  cryptsetup = "${pkgs.cryptsetup}/bin/cryptsetup";
  pkill = "${pkgs.procps}/bin/pkill";
in {
  # Inspiration drawn/copied from: https://mth.st/blog/nixos-initrd-ssh/
  boot.initrd = {
    enable = true;
    kernelModules = [ "nvme" ];
    luks.forceLuksSupportInInitrd = true;

    # It may be necessary to wait a bit for devices to be initialized.
    # See https://github.com/NixOS/nixpkgs/issues/98741
    preLVMCommands = lib.mkOrder 400 "${corebin}/sleep 1";

    network = {
      enable = true;
      ssh = {
        enable = true;
        port = 24060;
        authorizedKeys = config.users.users.x10an14.openssh.authorizedKeys.keys;
        hostKeys = [ "/etc/secrets/initrd/ssh/ssh_host_ed25519_key" "/etc/secrets/initrd/ssh/ssh_host_ecdsa_key" ];
      };

      # Set the shell profile to meet SSH connections with a decryption
      # prompt that writes to /tmp/continue if successful.
      postCommands = ''
        ${corebin}/cat >> /root/.profile <<-EOF
          ${cryptsetup} luksOpen ${config.btrfsDevices.root.lockedDeviceId} cryptroot &&
          ${pkill} cryptsetup &&
          exit
        EOF
        ${corebin}/echo 'Starting sshd...'
      '';
    };

    # Block the boot process until either the below cryptsetup prompt is finished, or killed
    postDeviceCommands = lib.mkOrder 250 ''
      ${corebin}/echo 'Waiting for root device to get opened here, or unlocked through SSH on port ${toString config.boot.initrd.network.ssh.port}...'
      ${cryptsetup} luksOpen ${config.btrfsDevices.root.lockedDeviceId} cryptroot

      ${corebin}/mkdir -p /swp/persist
      # Sleep to ensure availability of block devices
      ${corebin}/sleep 2
      ${mountbin}/mount -o subvol=@persist ${config.btrfsDevices.root.unlockedDeviceId} /swp/persist

      ${corebin}/sleep 2
      ${cryptsetup} luksOpen ${config.btrfsDevices.swap.lockedDeviceId} --key-file /swp/persist/etc/secrets/initrd/luks/swap.key cryptswap
      ${mountbin}/umount /swp/persist
    '';
  };
}
