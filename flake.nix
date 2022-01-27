{
  # Inspired/stolen from: https://hoverbear.org/blog/nix-flake-live-media/
  description = "x10an4's NixOS Live ISO image";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
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
    };
  in {
    nixosConfigurations = let
      # Shared base configuration.
      baseConfig = {
        system = systemArch;
        modules = [
          {nixpkgs.pkgs = pkgs;}

          # Common system modules...
          ./base/common/nix-store.nix
          ./base/common/sudo.nix
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
      initialSystem = nixpkgs.lib.nixosSystem {
        inherit (baseConfig) system;
        modules = baseConfig.modules ++ [
          {nixpkgs.pkgs = pkgs;}

          # Modules for installed systems only.
          ./config/encrypted-boot.nix
        ];
      };
      bits-laptop = nixpkgs.lib.nixosSystem {
        inherit (baseConfig) system;
        modules = baseConfig.modules ++ [
          {nixpkgs.pkgs = pkgs;}

          # Modules for installed systems only.
          ./config/encrypted-boot.nix
          inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t480
        ];
      };
    };
  };
}
