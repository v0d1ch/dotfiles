execute pathogen#infect()

syntax on
filetype plugin indent on

imap jk <Esc>
let mapleader = "<SPACE>"

set encoding=utf-8
set noswapfile
set nocompatible
set number
set showmode
 " Tab specific option
set tabstop=2                   "A tab is 2 spaces
set expandtab                   "Always uses spaces instead of tabs
set softtabstop=1               "Insert 2 spaces when tab is pressed
set shiftwidth=2                "An indent is 2 spaces
set shiftround                  "Round indent to nearest shiftwidth multiple

set background=dark
set colorcolumn=80
colorscheme palenight

set term=xterm-256color
set clipboard=unnamed
set scrolljump=5
set nowrap
set ignorecase
set nocursorline
set lazyredraw
set incsearch hlsearch

set completeopt=menuone,menu,longest
set completeopt+=longest
set laststatus=2

set wildignore+=*\\tmp\\*,*.swp,*.swo,*.zip,.git,.cabal-sandbox
set wildmode=longest,list,full
set wildmenu
set list
set showbreak=↪\
set listchars=tab:→\ ,eol:↲,nbsp:␣,trail:•,extends:⟩,precedes:⟨
set ttyfast
set runtimepath^=~/.vim/bundle/ctrlp.vim

let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_cache_dir = $HOME . '/.cache/ctrlp'
if executable('rg')
  set grepprg=rg\ --color=never
  let g:ctrlp_user_command = 'rg %s --files --color=never --glob ""'
  let g:ctrlp_use_caching = 0
endif
let g:ctrlp_match_window = 'results:50'
let g:ctrlp_working_path_mode = 'ra'
nnoremap <space>. :CtrlPTag<cr>
nnoremap <space>f :CtrlP<cr>
nnoremap <space>b :CtrlPBuffer<cr>

map <C-n> :NERDTreeToggle<CR>
nnoremap <space>nt :NERDTreeFind<CR>

autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'
"

let g:gitgutter_max_signs = 500
" "let g:airline_extensions = []
set ttimeoutlen=50
let g:airline#extensions#hunks#enabled=0
let g:airline#extensions#branch#enabled=1

if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif
let g:airline_symbols.space = "\ua0"
let g:airline_theme='base16_spacemacs'

" fugitive git bindings
nnoremap <space>ga :Git add %:p<CR><CR>
nnoremap <space>gs :Gstatus<CR>
nnoremap <space>gc :Gcommit -v -q<CR>
nnoremap <space>gt :Gcommit -v -q %:p<CR>
nnoremap <space>gd :Gdiff<CR>
nnoremap <space>ge :Gedit<CR>
nnoremap <space>gr :Gread<CR>
nnoremap <space>gw :Gwrite<CR><CR>
nnoremap <space>gl :silent! Glog<CR>:bot copen<CR>
nnoremap <space>gp :Ggrep<Space>
nnoremap <space>gm :Gmove<Space>
nnoremap <space>gb :Git branch<Space>
nnoremap <space>go :Git checkout<Space>


" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1

" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 1

" Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = 'left'

" Set a language to use its alternate delimiters by default
let g:NERDAltDelims_java = 1

" Add your own custom formats or override the defaults
let g:NERDCustomDelimiters = { 'haskell': { 'left': '--','right': '' } }

" Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDCommentEmptyLines = 1

" Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1

" Enable NERDCommenterToggle to check all selected lines is commented or not
let g:NERDToggleCheckAllLines = 1

map <space>cc <Plug>NERDCommenterComment
map <space>cd <Plug>NERDCommenterToggle

nnoremap <silent> <leader>d <Plug>DashSearch
nnoremap <silent> <space>+ :exe "resize " . (winheight(0) * 3/2)<CR>
nnoremap <silent> <space>- :exe "resize " . (winheight(0) * 2/3)<CR>
nnoremap <space>m :Merginal<CR>

let g:ackprg = 'rg -i --vimgrep --no-heading'
nnoremap <space>a :Ack! -n <Space>

"diff colors
set t_Co=88

set undolevels=4000
if exists('+undoreload')  | set undoreload=100000    | endif

if has('persistent_undo')
  " Make sure that the directory ~/UNDO exists
  " for persistent undo to work.
  set undodir=~/UNDO
  set undofile
endif

"remove trailing whitespace
autocmd BufWritePre *.* :%s/\s\+$//e

map <space>t <C-]>

map <space>h :wincmd h<CR>
map <space>j :wincmd j<CR>
map <space>k :wincmd k<CR>
map <space>l :wincmd l<CR>

vnoremap <space>r :! hindent <CR>
vnoremap <space>i :! stylish-haskell <CR>

map <space>nh :nohl <CR>

hi Search cterm=bold ctermfg=white ctermbg=red
hi Visual cterm=bold ctermfg=white ctermbg=blue

nnoremap <space>li :!hlint % <Enter>
nnoremap <space>ho :!hoogle <cword> <Enter>
