pkgs:
{
  enable = true;
  viAlias = true;
  vimAlias = true;
  plugins = with pkgs.vimPlugins; [
    nerdtree
    vim-surround
    vim-fugitive
    vimagit
    ctrlp

    # themes
    wombat256

    # Haskell
    vim-hoogle
    neco-ghc
    haskell-vim
    hlint-refactor-vim
    ghc-mod-vim

    # Nix
    vim-nix

  ];

  extraConfig = ''
    colorscheme wombat256mod

    set number
    set expandtab
    set foldmethod=indent
    set foldnestmax=5
    set foldlevelstart=99
    set foldcolumn=0

    set list
    set listchars=tab:>-

    let g:better_whitespace_enabled=1
    let g:strip_whitespace_on_save=1

    imap jk <Esc>
    let mapleader = "<SPACE>"

    "nerdtree
    map <C-n> :NERDTreeToggle<CR>
    autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
    "ctrl-p
    let g:ctrlp_map = '<c-p>'
    let g:ctrlp_cmd = 'CtrlP'
  '';
}
