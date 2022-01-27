{config, ...}:
{
  users = {
    groups.x10an14.gid = 1000;
    users."x10an14" = {
      uid = 1000;
      group = "x10an14";
      isNormalUser = true;
      password = ""; # Only for live media (USB iso)
      extraGroups = [ "wheel" "networkmanager" ];
      openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBHppoReyB4VyFyUumqm54ledY5uixcvfkmQnsCwtZHe" ];
    };
  };
}
