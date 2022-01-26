{
  # Inspired/stolen from: https://hoverbear.org/blog/nix-flake-live-media/
  description = "x10an4's NixOS Live ISO image";
  inputs.nixos.url = "github:nixos/nixpkgs/nixos-21.11";

  outputs = { self, nixos }: {
    nixosConfigurations = let
      # Shared base configuration.
      baseConfig = {
        system = "x86_64-linux";
        modules = [
          # Common system modules...
        ];
      };
    in {
      installIso = nixos.lib.nixosSystem {
        inherit (baseConfig) system;
        modules = baseConfig.modules ++ [
          "${nixos}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        ];
      };
      initialSystem = nixos.lib.nixosSystem {
        inherit (baseConfig) system;
        modules = baseConfig.modules ++ [
          # Modules for installed systems only.
        ];
      };
    };
  };
}
