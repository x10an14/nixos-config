{config, pkgs, ...}:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    configure = {
      customRC = ''
        "" https://stackoverflow.com/a/22676189
        " Put plugins and dictionaries in this dir (also on Windows)
        let vimDir= '$HOME/.vim'
        let &runtimepath.=','.vimDir

        " Keep undo history across sessions by storing it in a file
        if has('persistent_undo')
            let myUndoDir = expand(vimDir . '/undodir')
            " Create dirs
            call system('mkdir ' . vimDir)
            call system('mkdir ' . myUndoDir)
            let &undodir = myUndoDir
            set undofile
        endif

        " Make nvim remember code folding
        autocmd BufWinLeave *.* mkview
        autocmd BufWinEnter *.* silent loadview

        " https://askubuntu.com/a/202077 -> make nvim reopen file on line open last time
        if has("autocmd")
          au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
        endif

        " Activate rainbow parens/brackets
        let g:rainbow_active = 1
        " Use my own preferred color scheme
        let g:rainbow_conf = {
        \  'ctermfgs': ['blue', 'darkred', 'green', 'magenta', 'cyan', 'yellow']
        \}

        filetype indent plugin on
        set background=dark
        syntax enable
        set showmatch
        set cursorline
        set number
      '';
      packages.myVimPackage = with pkgs.vimPlugins; {
        # loaded on launch
        start = [
          fugitive
          vim-toml
          fzf-vim
          rainbow
          vim-nix
        ];
        # manually loadable by calling `:packadd $plugin-name`
        opt = [ ];
      };
    };
  };
}
