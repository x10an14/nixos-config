{ config, pkgs, ... }:
{
  nix = {
    gc.automatic = true;
    autoOptimiseStore = true;

    # Make use of latest `nix` to allow usage of `nix flake`s.
    package = pkgs.nix_2_5;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}
