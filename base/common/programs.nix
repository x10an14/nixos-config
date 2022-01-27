{config, pkgs, ...}:
{
  # List services that you want to enable:
  services = {
    openssh = {
      enable = true;
      passwordAuthentication = false;
      ports = [ 5124 ];
    };
    haveged.enable = true;
  };

  # Random minor program's config
  programs = {
    kbdlight.enable = true;
    tmux = {
      enable = true;
      newSession = true;
      keyMode = "vi";
      historyLimit = 9999999;
    };
  };
}
