{ config, lib, ... }:

{
  environment = {
    shellAliases = {
      la = "ls -Flasch";
      ls = "ls --color=auto";
      grep = "grep --color=auto";
      lsdisks = "lsblk -o name,type,size,fstype,partuuid,uuid,label,mountpoint";
      set-keyboard-backlight-level = "brightnessctl --device='tpacpi::kbd_backlight' set";
    };
    shellInit = ''
        HISTCONTROL=ignorespace
        shopt -s histappend
        HISTSIZE=-1
        HISTFILESIZE=-1
        # https://unix.stackexchange.com/q/132293
        HISTTIMEFORMAT="[%F %T] "
    '';
    interactiveShellInit = ''
      if command -v fzf-share >/dev/null; then
        FZFPATH="$(fzf-share)"
        source "$FZFPATH/key-bindings.bash"
        source "$FZFPATH/completion.bash"
      fi
    '';
  };

  programs.bash.promptInit = ''
    # https://stackoverflow.com/a/16715681
    returnCode="$?"

    # Set timestamp
    LEFT_PROMPT='[\D{%F %T}] '

    # Print returncode white, red if not equal to zero
    stopColoring='\[\033[00m\]'
    nonZeroReturnCodeColorStart='\[\033[0;31m\]'
    if [ $returnCode -eq 0 ]; then
      nonZeroReturnCodeColorStart=""
    fi
    LEFT_PROMPT+="$nonZeroReturnCodeColorStart$returnCode$stopColoring "

    # Save each command to history file as they're entered:
    history -a;

    # Print username, red for root, purple elsewise
    userNameColor='\[\033[0;35m\]'
    if [ "$(whoami)" = "root" ]; then
      userNameColor='\[\033[0;31m\]'
    fi
    LEFT_PROMPT+="$userNameColor\u$stopColoring@"

    # Finalize prompt:
    greenHostname='\[\033[01;32m\]\h'
    blueCwd='\[\033[01;34m\]\w'
    LEFT_PROMPT+="$greenHostname$stopColoring:$blueCwd$stopColoring\\n-> \$ "
    export PS1="$LEFT_PROMPT"
  '';

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
