pkgs:
{
  enable = true;
  viAlias = true;
  vimAlias = true;
  plugins = with pkgs.vimPlugins; [
    fzf-vim
    fzfWrapper
    LanguageClient-neovim
    lightline-vim
    nerdtree
    supertab
    tabular
    vim-better-whitespace
    vim-multiple-cursors
    vim-surround
    #vimproc
    #vimproc-vim

    # themes
    wombat256

    # language packages

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

    let g:SuperTabDefaultCompletionType = '<c-x><c-o>'

    if has("gui_running")
      imap <c-space> <c-r>=SuperTabAlternateCompletion("\<lt>c-x>\<lt>c-o>")<cr>
    else " no gui
      if has("unix")
        inoremap <Nul> <c-r>=SuperTabAlternateCompletion("\<lt>c-x>\<lt>c-o>")<cr>
      endif
    endif

    let g:haskellmode_completion_ghc = 0
    autocmd FileType haskell setlocal omnifunc=necoghc#omnifunc
    autocmd FileType markdown setlocal conceallevel=0

    " Tabular bindings
    let g:haskell_tabular = 1
    vmap <leader>a= :Tabularize /=<CR>
    vmap <leader>a; :Tabularize /::<CR>
    vmap <leader>a- :Tabularize /-><CR>
    vmap <leader>a# :Tabularize /#<CR>

    " fzf bindings
    nnoremap <leader>r :Rg<CR>
    nnoremap <leader>b :Buffers<CR>
    nnoremap <leader>e :Files<CR>
    nnoremap <leader>l :Lines<CR>
    nnoremap <leader>L :BLines<CR>
    nnoremap <leader>c :Commits<CR>
    nnoremap <leader>C :BCommits<CR>
  '';
}
