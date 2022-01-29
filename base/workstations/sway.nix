{config, ...}:
# Sway specific stuffs (fixes that must be system based - instead of home-manager based)
{
  # Allow Sway to create windows (eg. super+enter)
  hardware.opengl.enable = true;

  # Allow swaylock to unlock machine
  # Below line is necessary due to: https://github.com/NixOS/nixpkgs/issues/143365
  security.pam.services.swaylock = {};
}
