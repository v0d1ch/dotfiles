{pkgs, ...}:
{
  extraPlugins = with pkgs.vimPlugins;
   [ nvim-lspconfig 
   ];

}
