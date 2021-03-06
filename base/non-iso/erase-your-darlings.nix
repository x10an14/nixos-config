{config, lib, pkgs, ...}:
let
  corebin = "${pkgs.coreutils}/bin";
  awk = "${pkgs.gawk}/bin/awk";
  btrfs = "${pkgs.btrfs-progs}/bin/btrfs";
  mountbin = "${pkgs.mount}/bin";
  btrfs-root-diff = pkgs.writeShellApplication {
    name = "show-btrfs-root-snapshot-diff.sh";
    runtimeInputs = with pkgs; [
      btrfs-progs
      sudo
      coreutils
      mount
    ];
    text = builtins.readFile ./show-btrfs-root-snapshot-diff.sh;
  };
in {
  # Make a tool to see what's not yet persisted available for all via PATH
  environment.systemPackages = [
    btrfs-root-diff
  ];
  security.sudo.extraConfig = ''
    # rollback results in sudo lectures after each reboot
    Defaults lecture = never
  '';

  # SSH host keys persist between each boot:
  services.openssh.hostKeys = [
    {
      path = "/persist/etc/secrets/sshd/ssh_host_ed25519_key";
      type = "ed25519";
    }
    {
      path = "/persist/etc/secrets/sshd/ssh_host_ecdsa_key";
      type = "ecdsa";
    }
  ];  

  # Files which should persist between each boot:
  environment.etc = {
    # Retain NixOS config
    secrets.source = "/persist/etc/secrets";
    nixos.source = "/persist/etc/nixos";

    # Retain user passwords...
    shadow.source = "/persist/etc/shadow";

    # Wi-Fi connections
    "NetworkManager/system-connections".source = "/persist/etc/NetworkManager/system-connections";

    NIXOS.source = "/persist/etc/NIXOS";
    machine-id.source = "/persist/etc/machine-id";
  };
  systemd.tmpfiles.rules = [
    "L /var/lib/fwupd - - - - /persist/var/lib/fwupd"
    "L /root/.bash_history - - - - /persist/root/.bash_history"
    "L /var/lib/NetworkManager/secret_key - - - - /persist/var/lib/NetworkManager/secret_key"
    "L /var/lib/NetworkManager/seen-bssids - - - - /persist/var/lib/NetworkManager/seen-bssids"
    "L /var/lib/NetworkManager/timestamps - - - - /persist/var/lib/NetworkManager/timestamps"
  ];

  # Note `lib.mkBefore` is used instead of `lib.mkAfter` here.
  boot.initrd.postDeviceCommands = pkgs.lib.mkOrder 500 ''
    mkdir -p /foo

    # We first mount the btrfs root to /foo
    # so we can manipulate btrfs subvolumes.
    echo "Mounting unlocked root device so as to erase-the-darlings..."
    mount -o subvol=@ ${config.btrfsDevices.root.unlockedDeviceId} /foo || mount | grep '/foo'
    sleep 1

    echo "Deleting btrfs subvolumes:"
    # While we're tempted to just delete /root and create
    # a new snapshot from /root-blank, /root is already
    # populated at this point with a number of subvolumes,
    # which makes `btrfs subvolume delete` fail.
    # So, we remove them first.
    subvolume list -o /foo/ |
    -F'@/' '{print $2}' |
    while read subvolume; do
      echo -e "\\tdeleting $subvolume subvolume..."
      subvolume delete "/foo/$subvolume"
    done
    sleep 1
    echo -e "\\tdeleting root (/) subvolume..."
    subvolume delete \
      --subvolid $(btrfs subvolume list /foo | grep 'path @$' | ${awk} '{print $2}') \
      /foo

    # Need do re-mount for unknown reasons (:x10an14)
    #   Maybe to let btrfs finish committing deletion?
    umount /foo
    sleep 1
    echo "Re-creating root subvolume from blank snapshot..."
    mount ${config.btrfsDevices.root.unlockedDeviceId} /foo

    # Roll back @ subvolume/re-create it from blank-root snapshot:
    mkdir /blank
    mount -o subvol=blank-root ${config.btrfsDevices.root.unlockedDeviceId} /blank
    echo "restoring blank root (/) subvolume..."
    subvolume snapshot /blank /foo/@

    # Once we're done rolling back to a blank snapshot,
    # we can unmount /foo and continue on the boot process.
    umount /foo
    umount /blank
  '';
}
