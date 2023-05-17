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
              lazygit-nvim
              tokyonight-nvim 
              vim-illuminate
              project-nvim
              nvim-web-devicons
              lualine-nvim
              popup-nvim
              comment-nvim 
              nvim-web-devicons
              alpha-nvim
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

          set background=dark
          set whichwrap+=<,>,[,]
          "prevent enter in autocomplete suggestions to mess things up
          inoremap <expr> <CR> pumvisible() ? "\<C-Y>" : "\<CR>"

          autocmd FileType gitrebase vnoremap <buffer> <localleader>p :s/\v^(pick\|reword\|edit\|squash\|fixup\|exec\|drop)/pick/<cr>

          let g:solarized_italic_comments = v:true
          let g:solarized_italic_keywords = v:false
          let g:solarized_italic_functions = v:false
          let g:solarized_italic_variables = v:false
          let g:solarized_contrast = v:true
          let g:solarized_borders = v:false
          let g:solarized_disable_background = v:false

          colorscheme tokyonight

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

          nnoremap <Leader>g  :LazyGit<CR> 
          nnoremap <Leader>f  :Telescope find_files<CR>
          nnoremap <Leader>s  :Telescope live_grep<CR>
          nnoremap <Leader>rs :Telescope resume<CR>
          nnoremap <Leader>b  :Buffers<CR>
          nnoremap <Leader>q  :call FormatCode()<CR>
          
          " format on save
          augroup RunCommandOnWrite
            autocmd BufWritePost *.hs :call FormatCode()
          augroup END


          nmap <Leader>d <Plug>(coc-definition)
          nmap <Leader>t <Plug>(coc-type-definition)
          nmap <Leader>gr <Plug>(coc-references)
          nmap <Leader>gi <Plug>(coc-implementation)
          nmap <Leader>p :Telescope projects<CR> 

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


          " Mappings for CoCList
          nmap <Leader>t :call CocActionAsync('doHover')<CR>
          nmap <Leader>z :CocDiagnostics<CR>

          "" Search workspace symbols
          nnoremap <silent><nowait> <Leader>l  :<C-u>CocList -I symbols<cr>

          " Add `:Format` command to format current buffer
          command! -nargs=0 Format :call CocActionAsync('format')

          nnoremap <Leader>K :call ShowDocumentation()<CR>

          " projects
          lua << EOF
            require("project_nvim").setup {
               -- Manual mode doesn't automatically change your root directory, so you have
               -- the option to manually do so using `:ProjectRoot` command.
               manual_mode = false,

               -- Methods of detecting the root directory. **"lsp"** uses the native neovim
               -- lsp, while **"pattern"** uses vim-rooter like glob pattern matching. Here
               -- order matters: if one is not detected, the other is used as fallback. You
               -- can also delete or rearangne the detection methods.
               detection_methods = { "lsp", "pattern" },

               -- All the patterns used to detect root dir, when **"pattern"** is in
               -- detection_methods
               patterns = { ".git", ".cabal"},

               -- Table of lsp clients to ignore by name
               -- eg: { "efm", ... }
               ignore_lsp = {},

               -- Don't calculate root dir on specific directories
               -- Ex: { "~/.cargo/*", ... }
               exclude_dirs = {},

               -- Show hidden files in telescope
               show_hidden = false,

               -- When set to false, you will get a message when project.nvim changes your
               -- directory.
               silent_chdir = true,

               -- What scope to change the directory, valid options are
               -- * global (default)
               -- * tab
               -- * win
               scope_chdir = 'global',

               -- Path where project.nvim will store the project history for use in
               -- telescope
               datapath = vim.fn.stdpath("data"),
            }

            require('telescope').load_extension('projects')

            require('lualine').setup {
              options = {
                icons_enabled = true,
                theme = 'auto',
                component_separators = { left = '', right = ''},
                section_separators = { left = '', right = ''},
                disabled_filetypes = {
                  statusline = {},
                  winbar = {},
                },
                ignore_focus = {},
                always_divide_middle = true,
                globalstatus = false,
                refresh = {
                  statusline = 1000,
                  tabline = 1000,
                  winbar = 1000,
                }
              },
              sections = {
                lualine_a = {'mode'},
                lualine_b = {'branch', 'diff','filename'},
                lualine_c = {'diagnostics',

                   -- Table of diagnostic sources, available sources are:
                   --   'nvim_lsp', 'nvim_diagnostic', 'nvim_workspace_diagnostic', 'coc', 'ale', 'vim_lsp'.
                   -- or a function that returns a table as such:
                   --   { error=error_cnt, warn=warn_cnt, info=info_cnt, hint=hint_cnt }
                   sources = { 'coc'},

                   -- Displays diagnostics for the defined severity types
                   sections = { 'error', 'warn', 'info', 'hint' },

                   diagnostics_color = {
                     -- Same values as the general color option can be used here.
                     error = 'DiagnosticError', -- Changes diagnostics' error color.
                     warn  = 'DiagnosticWarn',  -- Changes diagnostics' warn color.
                     info  = 'DiagnosticInfo',  -- Changes diagnostics' info color.
                     hint  = 'DiagnosticHint',  -- Changes diagnostics' hint color.
                   },
                   symbols = {error = 'E', warn = 'W', info = 'I', hint = 'H'},
                   colored = true,           -- Displays diagnostics status in color if set to true.
                   update_in_insert = false, -- Update diagnostics in insert mode.
                   always_visible = false,   -- Show diagnostics even if there are none.


                },
                lualine_x = {'coc#status', 'encoding', 'fileformat', 'filetype'},




                lualine_y = {'progress'},
                lualine_z = {'location'}
              },
              inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = {'filename'},
                lualine_x = {'location'},
                lualine_y = {},
                lualine_z = {}
              },
              tabline = {},
              winbar = {},
              inactive_winbar = {},
              extensions = {}
            }

            require('Comment').setup{
              ---Add a space b/w comment and the line
                  padding = true,
                  ---Whether the cursor should stay at its position
                  sticky = true,
                  ---Lines to be ignored while (un)comment
                  ignore = nil,
                  ---LHS of toggle mappings in NORMAL mode
                  toggler = {
                      ---Line-comment toggle keymap
                      line = 'gcc',
                      ---Block-comment toggle keymap
                      block = 'gbc',
                  },
                  ---LHS of operator-pending mappings in NORMAL and VISUAL mode
                  opleader = {
                      ---Line-comment keymap
                      line = 'gc',
                      ---Block-comment keymap
                      block = 'gb',
                  },
                  ---LHS of extra mappings
                  extra = {
                      ---Add comment on the line above
                      above = 'gcO',
                      ---Add comment on the line below
                      below = 'gco',
                      ---Add comment at the end of line
                      eol = 'gcA',
                  },
                  ---Enable keybindings
                  ---NOTE: If given `false` then the plugin won't create any mappings
                  mappings = {
                      ---Operator-pending mapping; `gcc` `gbc` `gc[count]{motion}` `gb[count]{motion}`
                      basic = true,
                      ---Extra mapping; `gco`, `gcO`, `gcA`
                      extra = true,
                  },
                  ---Function to call before (un)comment
                  pre_hook = nil,
                  ---Function to call after (un)comment
                  post_hook = nil,
                  }
            require'alpha'.setup(require'alpha.themes.dashboard'.config)
          EOF

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
