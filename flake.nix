{
  # Inspired/stolen from: https://hoverbear.org/blog/nix-flake-live-media/
  description = "x10an4's NixOS Live ISO image";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
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
        system = "x86_64-linux";
        modules = [
          # Common system modules...
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
