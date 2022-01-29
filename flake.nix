{
  # Inspired/stolen from: https://hoverbear.org/blog/nix-flake-live-media/
  description = "x10an4's NixOS Live ISO image";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "flake:nixpkgs";
    nixos-hardware.url = "flake:nixos-hardware";
  };

  outputs = inputs@{
    self
    , nixpkgs
    , ...
  }: let
    systemArch = "x86_64-linux";

    # Allow the referencing of unstable packages with `pkgs.unstable.<package>`:
    # Inspired by: https://dzone.com/articles/nixos-home-manager-on-native-nix-flake-installatio
    overlay-unstable = final: prev: {
      inherit systemArch;
      unstable = inputs.nixpkgs-unstable.legacyPackages."${systemArch}";
    };
    pkgs = import nixpkgs {
      inherit systemArch overlay-unstable;
      system = systemArch;
      overlays = [ overlay-unstable ];
      config = { allowUnfree = true; };
    };
  in {
    nixosConfigurations = let
      # Shared base configuration.
      baseConfig = {
        system = systemArch;
        modules = [
          {nixpkgs.pkgs = pkgs;}

          # Common system modules...
          ./base/common/fwupd.nix
          ./base/common/git.nix
          ./base/common/neovim.nix
          ./base/common/networking.nix
          ./base/common/nix-store.nix
          ./base/common/packages.nix
          ./base/common/programs.nix
          ./base/common/shell-environment.nix
          ./base/common/sound.nix
          ./base/common/sudo.nix
          ./base/common/x10an14.nix
          ./base/common/yubikeys-gpg.nix
        ];
      };
    in {
      installIso = nixpkgs.lib.nixosSystem {
        inherit (baseConfig) system;
        modules = baseConfig.modules ++ [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          ./machine-configurations/iso.nix
        ];
      };
      bits-laptop = nixpkgs.lib.nixosSystem {
        inherit (baseConfig) system;
        modules = baseConfig.modules ++ [
          {nixpkgs.pkgs = pkgs;}

          # Modules for installed systems only.
          ./machine-configurations/bits-laptop.nix
          inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t480
        ];
      };
    };
  };
}
