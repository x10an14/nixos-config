{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    yubikey-personalization
    yubikey-touch-detector
    gnupg pinentry-curses
    ccid # So as to enable resets and stuffs of yubikey
    yubikey-manager
  ];

  programs.ssh.startAgent = false;
  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "curses";
    enableSSHSupport = true;
    enableExtraSocket = true;
  };

  # To allow smartcard communication with gpg/gpg-agent
  services.pcscd.enable = true;
  services.udev.packages = with pkgs; [
    yubikey-personalization
  ];
}
