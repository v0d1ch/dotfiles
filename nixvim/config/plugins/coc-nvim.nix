{pkgs, inputs, opts, ...}:
{
  extraPlugins = with pkgs.vimPlugins; [ coc-nvim ];
  ## here we need to make sure enter works for selecting the suggestion
  extraConfigVim = '' 
    xmap <leader>a  <Plug>(coc-codeaction-selected)
    nmap <leader>a  <Plug>(coc-codeaction-selected)
    nmap <Leader>z :CocDiagnostics<CR>
    inoremap <expr> <CR> pumvisible() ? "\<C-Y>" : "\<CR>" 
  ''; 

}
