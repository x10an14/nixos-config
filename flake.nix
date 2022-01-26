{
  # Inspired/stolen from: https://hoverbear.org/blog/nix-flake-live-media/
  description = "x10an4's NixOS Live ISO image";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = {
    self
    , nixpkgs
    , ...
  }: let
    systemArch = "x86_64-linux";
  in {
    nixosConfigurations = let
      # Shared base configuration.
      baseConfig = {
        system = systemArch;
        modules = [
          # Common system modules...
          ./base/common/nix-store.nix
        ];
      };
    in {
      installIso = nixpkgs.lib.nixosSystem {
        inherit (baseConfig) system;
        modules = baseConfig.modules ++ [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        ];
      };
      initialSystem = nixpkgs.lib.nixosSystem {
        inherit (baseConfig) system;
        modules = baseConfig.modules ++ [
          # Modules for installed systems only.
        ];
      };
    };
  };
}
