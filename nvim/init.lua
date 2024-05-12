vim.cmd[[
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

          " reload the file if it changes on disk
          set autoread

          set background=dark
          set whichwrap+=<,>,[,]
          set foldmethod=syntax

          "prevent enter in autocomplete suggestions to mess things up
          inoremap <expr> <CR> pumvisible() ? "\<C-Y>" : "\<CR>"

          "latex
          " Viewer options: One may configure the viewer either by specifying a built-in
          " viewer method:
          let g:vimtex_view_method = 'zathura'
          
          " Or with a generic interface:
          let g:vimtex_view_general_viewer = 'okular'
          let g:vimtex_view_general_options = '--unique file:@pdf\#src:@line@tex'
          
          " VimTeX uses latexmk as the default compiler backend. If you use it, which is
          " strongly recommended, you probably don't need to configure anything. If you
          " want another compiler backend, you can change it as follows. The list of
          " supported backends and further explanation is provided in the documentation,
          " see ":help vimtex-compiler".
          "let g:vimtex_compiler_method = 'latexrun'

          autocmd FileType gitrebase vnoremap <buffer> <localleader>p :s/\v^(pick\|reword\|edit\|squash\|fixup\|exec\|drop)/pick/<cr>

          let g:solarized_italic_comments = v:true
          let g:solarized_italic_keywords = v:false
          let g:solarized_italic_functions = v:false
          let g:solarized_italic_variables = v:false
          let g:solarized_contrast = v:true
          let g:solarized_borders = v:false
          let g:solarized_disable_background = v:false

          " colorscheme tokyonight
          " colorscheme PaperColor 

          set showcmd
          set clipboard+=unnamedplus
          set t_Co=256
          set noswapfile
          set number
          set hlsearch
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
          let g:rustc_path = $HOME."/.nix-profile/bin/rustc"

          let mapleader = " "
          "nerdtree
          map <leader>n :NERDTreeToggle<CR>
          map <leader>o :NERDTreeFind %<CR>
          "autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
          nnoremap * :keepjumps normal! mi*`i<CR>
          nnoremap <Leader>g  :Neogit<CR> 
          nnoremap <Leader>f  :Telescope find_files<CR>
          nnoremap <Leader>rs :Telescope resume<CR>
          nnoremap <Leader>b  :Buffers<CR>
          nnoremap <Leader>q  :call FormatCode()<CR>
          nnoremap <Leader>w  :lua require("spectre").open_visual({select_word=true})<CR>
          nnoremap <Leader>cw :lua require("spectre").open_file_search({select_word=true})<CR>
          nnoremap <Leader>s  :lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>
          nnoremap <Leader>j <cmd>lua require('telescope.builtin').grep_string({search = vim.fn.expand("<cword>")})<CR>
          nnoremap <Leader>k  :Telescope current_buffer_fuzzy_find<CR>
          nnoremap <Leader>q  :CocRestart<CR> 
          nnoremap <C-s> :Scratch<CR>
          
          " format on save
          augroup RunCommandOnWrite
             autocmd BufWritePost *.hs :call FormatCode()
          augroup END

          " format cabal files on save
          augroup RunCommandOnWrite
            autocmd BufWritePost *.cabal :call FormatCabalCode()
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

          " lazygit open file in vim
          if has('nvim') && executable('nvr')
            let $GIT_EDITOR = "nvr -cc split --remote-wait +'set bufhidden=wipe'"
          endif
  
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

          function! FormatCabalCode()
             :execute '%!cabal-fmt -i %'
          endfunction

          function! s:ScratchGenerator()
            echom "Creating scratch..."
            exe "new" . "[Scratch]"
            echom "Scratch created!"
          endfunction
          
          function! s:ScratchMarkBuffer()
            setlocal buftype=nofile
            setlocal bufhidden=hide
            setlocal noswapfile
          endfunction
          
          autocmd BufNewFile [Scratch] call s:ScratchMarkBuffer()
          command! Scratch call s:ScratchGenerator()


          highlight ConflictMarkerBegin guibg=#2f7366
          highlight ConflictMarkerOurs guibg=#2e5049
          highlight ConflictMarkerTheirs guibg=#344f69
          highlight ConflictMarkerEnd guibg=#2f628e
          highlight ConflictMarkerCommonAncestorsHunk guibg=#754a81


         ]]

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
            require('telescope').load_extension('fzf')

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
            require('spectre').setup()
            require('nvim-cursorline').setup {
              cursorline = {
                enable = true,
                timeout = 1000,
                number = false,
              },
              cursorword = {
                enable = true,
                min_length = 3,
                hl = { underline = true },
              }
            }
            local telescope = require("telescope")
            local lga_actions = require("telescope-live-grep-args.actions")
            
            telescope.setup {
              extensions = {
                fzf = {
                       fuzzy = true,                    -- false will only do exact matching
                       override_generic_sorter = true,  -- override the generic sorter
                       override_file_sorter = true,     -- override the file sorter
                       case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                                                        -- the default case_mode is "smart_case"
                },
                live_grep_args = {
                  auto_quoting = true, -- enable/disable auto-quoting
                  -- define mappings, e.g.
                  mappings = { -- extend mappings
                    i = {
                      ["<C-k>"] = lga_actions.quote_prompt(),
                      ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
                    },
                  },
                  -- ... also accepts theme settings, for example:
                  theme = "dropdown", -- use dropdown theme
                  -- theme = { }, -- use own theme spec
                  -- layout_config = { mirror=true }, -- mirror preview pane
                }
              }
            }
            local rt = require("rust-tools")
            
            rt.setup({
              server = {
                on_attach = function(_, bufnr)
                  -- Hover actions
                  vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
                  -- Code action groups
                  vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
                end,
              },
            })

            require("catppuccin").setup({
                flavour = "mocha", -- latte, frappe, macchiato, mocha
                background = { -- :h background
                    light = "latte",
                    dark = "mocha",
                },
                transparent_background = false, -- disables setting the background color.
                show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
                term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
                dim_inactive = {
                    enabled = false, -- dims the background color of inactive window
                    shade = "dark",
                    percentage = 0.15, -- percentage of the shade to apply to the inactive window
                },
                no_italic = false, -- Force no italic
                no_bold = false, -- Force no bold
                no_underline = false, -- Force no underline
                styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
                    comments = { "italic" }, -- Change the style of comments
                    conditionals = { "italic" },
                    loops = {},
                    functions = {},
                    keywords = {},
                    strings = {},
                    variables = {},
                    numbers = {},
                    booleans = {},
                    properties = {},
                    types = {},
                    operators = {},
                },
                color_overrides = {},
                custom_highlights = {},
                integrations = {
                    cmp = true,
                    gitsigns = true,
                    nvimtree = true,
                    neogit = true,
                    treesitter = true,
                    notify = false,
                    mini = {
                        enabled = true,
                        indentscope_color = "",
                    },
                    -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
                },
            })

            require('gitsigns').setup {
              signs = {
                add          = { text = '│' },
                change       = { text = '│' },
                delete       = { text = '_' },
                topdelete    = { text = '‾' },
                changedelete = { text = '~' },
                untracked    = { text = '┆' },
              },
              signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
              numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
              linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
              word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
              watch_gitdir = {
                follow_files = true
              },
              attach_to_untracked = true,
              current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
              current_line_blame_opts = {
                virt_text = true,
                virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
                delay = 1000,
                ignore_whitespace = false,
                virt_text_priority = 100,
              },
              current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
              sign_priority = 6,
              update_debounce = 100,
              status_formatter = nil, -- Use default
              max_file_length = 40000, -- Disable if file is longer than this (in lines)
              preview_config = {
                -- Options passed to nvim_open_win
                border = 'single',
                style = 'minimal',
                relative = 'cursor',
                row = 0,
                col = 1
              },
              yadm = {
                enable = false
              },
              on_attach = function(bufnr)
                  local gs = package.loaded.gitsigns
              
                  local function map(mode, l, r, opts)
                    opts = opts or {}
                    opts.buffer = bufnr
                    vim.keymap.set(mode, l, r, opts)
                  end
              
                  -- Navigation
                  map('n', ']c', function()
                    if vim.wo.diff then return ']c' end
                    vim.schedule(function() gs.next_hunk() end)
                    return '<Ignore>'
                  end, {expr=true})
              
                  map('n', '[c', function()
                    if vim.wo.diff then return '[c' end
                    vim.schedule(function() gs.prev_hunk() end)
                    return '<Ignore>'
                  end, {expr=true})
              
                  -- Actions
                  map('n', '<leader>hs', gs.stage_hunk)
                  map('n', '<leader>hr', gs.reset_hunk)
                  map('v', '<leader>hs', function() gs.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
                  map('v', '<leader>hr', function() gs.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
                  map('n', '<leader>hS', gs.stage_buffer)
                  map('n', '<leader>hu', gs.undo_stage_hunk)
                  map('n', '<leader>hR', gs.reset_buffer)
                  map('n', '<leader>hp', gs.preview_hunk)
                  map('n', '<leader>hb', function() gs.blame_line{full=true} end)
                  map('n', '<leader>tb', gs.toggle_current_line_blame)
                  map('n', '<leader>hd', gs.diffthis)
                  map('n', '<leader>hD', function() gs.diffthis('~') end)
                  map('n', '<leader>td', gs.toggle_deleted)
              
                  -- Text object
                  map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
                end
            }

            -- setup must be called before loading
            vim.cmd.colorscheme "catppuccin-mocha"

            -- Put anything you want to happen only in Neovide here
            if vim.g.neovide then
               vim.o.guifont = "monospace:h11" 
               -- vim.keymap.set('n', '<C-s>', ':w<CR>') -- Save
               -- vim.keymap.set('v', '<C-c>', '"+y') -- Copy
               -- vim.keymap.set('n', '<C-v>', '"+P') -- Paste normal mode
               -- vim.keymap.set('v', '<C-v>', '"+P') -- Paste visual mode
               vim.keymap.set('c', '<C-v>', '<C-R>+') -- Paste command mode
               vim.keymap.set('i', '<C-v>', '<ESC>l"+Pli') -- Paste insert mode

               vim.g.neovide_scale_factor = 1.0
               local change_scale_factor = function(delta)
                 vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
               end
               vim.keymap.set("n", "<C-=>", function()
                 change_scale_factor(1.25)
               end)
               vim.keymap.set("n", "<C-->", function()
                 change_scale_factor(1/1.25)
               end)
            end



            local neogit = require('neogit')
            neogit.setup {
              integrations = {
                  diffview = true,
                  telescope = true
              },
              status = {
                  recent_commit_count = 100,
              },
            }

