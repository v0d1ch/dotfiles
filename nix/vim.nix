{ pkgs, ... }:
{
  environment.variables = { EDITOR = "vim"; };

  environment.systemPackages = with pkgs; [
     (neovim.override {
        vimAlias = true;
        viAlias = true;
        withNodeJs = true;
        configure = {
          packages.myPlugins = with pkgs.vimPlugins; {
            start = [
              fugitive 
              nerdtree
              nerdcommenter
              # vimagit
              neogit

              awesome-vim-colorschemes 
              catppuccin-nvim
              vim-airline
              vim-airline-themes
              solarized              

              vim-lastplace
              plenary-nvim
              nvim-treesitter
              direnv-vim
              telescope-nvim
              telescope-coc-nvim
              telescope_hoogle
              completion-nvim

              vim-nix
              vim-cool
              haskell-vim 
              rust-tools-nvim 
              nvim-lspconfig
              fzf-vim
              coc-nvim
              haskell-tools-nvim
            ]; 
            opt = [];
        };
        customRC = ''
          " vim configuration
          set encoding=utf-8
          " Some servers have issues with backup files, see #649
          set nobackup
          set nowritebackup
          
          " Having longer updatetime (default is 4000 ms = 4s) leads to noticeable
          " delays and poor user experience
          set updatetime=300
          
          " Always show the signcolumn, otherwise it would shift the text each time
          " diagnostics appear/become resolved
          set signcolumn=yes

          set background=light
          set whichwrap+=<,>,[,]
          "prevent enter in autocomplete suggestions to mess things up
          inoremap <expr> <CR> pumvisible() ? "\<C-Y>" : "\<CR>"

          let g:solarized_italic_comments = v:true
          let g:solarized_italic_keywords = v:false
          let g:solarized_italic_functions = v:false
          let g:solarized_italic_variables = v:false
          let g:solarized_contrast = v:true
          let g:solarized_borders = v:false
          let g:solarized_disable_background = v:false
          "let g:airline_solarized_bg='dark'
          let g:airline_theme='badwolf'

          colorscheme solarized 

          set showcmd
          set clipboard=unnamedplus
          set t_Co=256
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
          let g:coc_data_home = $HOME . '/.config/coc'
          let mapleader = " "
          "nerdtree
          map <leader>n :NERDTreeToggle<CR>
          map <leader>o :NERDTreeToggle %<CR>
          autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
          nnoremap <Leader>g :Neogit<CR> 
          nnoremap <Leader>s :Files<CR>
          nnoremap <Leader>rs :Rg<CR>
          nnoremap <Leader>b :Buffers<CR>
          nnoremap <Leader>f :call FormatCode()<CR>

          nmap <Leader>d <Plug>(coc-definition)
          nmap <Leader>t <Plug>(coc-type-definition)
          nmap <Leader>gr <Plug>(coc-references)
          nmap <Leader>gi <Plug>(coc-implementation)

          "xmap <Leader>f  <Plug>(coc-format-selected)
          "nmap <Leader>f  <Plug>(coc-format-selected)

          " Applying code actions to the selected code block
          " Example: `<leader>aap` for current paragraph
          xmap <Leader>a  <Plug>(coc-codeaction-selected)
          nmap <Leader>a  <Plug>(coc-codeaction-selected)
          
          " Remap keys for applying code actions at the cursor position
          nmap <Leader>ac  <Plug>(coc-codeaction-cursor)
          " Remap keys for apply code actions affect whole buffer
          nmap <Leader>as  <Plug>(coc-codeaction-source)
          " Apply the most preferred quickfix action to fix diagnostic on the current line
          nmap <Leader>qf  <Plug>(coc-fix-current)
          
          " Remap keys for applying refactor code actions
          nmap <Leader>[ <Plug>(coc-diagnostic-prev)
          nmap <Leader>] <Plug>(coc-diagnostic-next)
          "nmap <silent> <Leader>re <Plug>(coc-codeaction-refactor)
          "xmap <silent> <Leader>r  <Plug>(coc-codeaction-refactor-selected)
          "nmap <silent> <Leader>r  <Plug>(coc-codeaction-refactor-selected)


          " Mappings for CoCList
          " show type on hover
          "autocmd CursorHold * silent call CocActionAsync('doHover')
          nmap <Leader>t :call CocActionAsync('doHover')<CR>
          nmap <Leader>z :CocDiagnostics<CR>

          " Show all diagnostics
          "nnoremap <silent><nowait> <Leader>z  :<C-u>CocList diagnostics<cr>
          "" Search workspace symbols
          nnoremap <silent><nowait> <Leader>l  :<C-u>CocList -I symbols<cr>

          "" Manage extensions
          "nnoremap <silent><nowait> <Leader>e  :<C-u>CocList extensions<cr>
          "" Show commands
          "nnoremap <silent><nowait> <Leader>c  :<C-u>CocList commands<cr>
          "" Find symbol of current document
          "nnoremap <silent><nowait> <Leader>o  :<C-u>CocList outline<cr>
          "" Do default action for next item
          "nnoremap <silent><nowait> <Leader>j  :<C-u>CocNext<CR>
          "" Do default action for previous item
          "nnoremap <silent><nowait> <Leader>k  :<C-u>CocPrev<CR>
          "" Resume latest coc list
          "nnoremap <silent><nowait> <Leader>p  :<C-u>CocListResume<CR>


          " Add `:Format` command to format current buffer
          command! -nargs=0 Format :call CocActionAsync('format')

          nnoremap <Leader>K :call ShowDocumentation()<CR>

          function! ShowDocumentation()
            if CocAction('hasProvider', 'hover')
              call CocActionAsync('doHover')
            else
              call feedkeys('K', 'in')
            endif
          endfunction

          function! FormatCode()
             let save_pos = getpos(".")
             :execute '%!fourmolu -q %'
             call setpos(".", save_pos)
          endfunction
        '';
        };
      })

  ];
}
