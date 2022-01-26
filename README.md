# x10an14's NixOS config

This repo is my NixOS flake'd config, initiated/inspired by: https://hoverbear.org/blog/nix-flake-live-media/

## How to update system
```
sudo nixos-rebuild switch --flake ".#$(hostname)"
```
### How to test build of system
```
nix build .#nixosConfigurations.initialSystem.config.system.build.toplevel
```

## How to make ISO and install on new machine
```
nix build .#nixosConfigurations.installIso.config.system.build.isoImage
test "$(ls result/iso/*.iso | wc -w)" -eq "1" # Should return returncode 0
cp -vi result/iso/*.iso /dev/sd<usb drive letter>
```

### On new machine
From booted live media, after formatting of disks/set-up is complete
```
sudo nixos-install --flake .#initialSystem
```

