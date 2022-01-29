{config, pkgs, ...}:
{
  sound.enable = true;

  # Installed for controlling volume through a cli
  environment.systemPackages = [pkgs.pamixer];

  ## Won't work without this?
  services.pipewire = {
    enable = true;

    # Simulate backends for programs expecting them
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;

  };
}
