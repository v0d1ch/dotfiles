{
  # Import all your configuration modules here
  imports =
    [ ./options/options.nix
      ./options/keymap.nix
      ./autocmd.nix
      # ./options/colorscheme.nix 
      ./plugins/tokyodark.nix 
      ./plugins/bufferline.nix
      ./plugins/treesitter.nix
      ./plugins/gitsigns.nix
      ./plugins/ufo.nix
      ./plugins/comment.nix
      ./plugins/ctrlsf.nix
      ./plugins/dashboard.nix
      ./plugins/lualine.nix
      ./plugins/telescope.nix 
      ./plugins/coc-nvim.nix
      ./plugins/copilot.nix
      ./plugins/project.nix
      ./plugins/plugins.nix
    ];
}
