{config, pkgs, ...}:
{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Enable `nix-locate <file>`
    nix-index

    # Misc. tools that are nice to have
    wget curl
    htop tree pstree
    shellcheck gnused
    lsof file pciutils killall

    # Niceties for terminal interactions
    bat
    direnv
    fzf
    git
    jq
    ripgrep-all
    tmux
    unzip
    yq

    # Packages which I install with additional extensions/plugins
    (pass-nodmenu.withExtensions (ps: with ps; [
        pass-audit
        pass-otp
        pass-genphrase
        pass-update
    ]))
    (python3.withPackages (e: [
      e.ipython
      e.requests
    ]))

    # Hardware management
    brightnessctl
    efibootmgr
    upower
    fwupd
    lm_sensors
  ];
}
