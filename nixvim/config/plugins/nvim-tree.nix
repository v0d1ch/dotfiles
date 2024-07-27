{mkKey,...}:
let
  inherit (mkKey) mkKeymap;
in {

  plugins.nvim-tree = { 
        enable = false;
  };

  keymaps = [
    (mkKeymap "n" "<leader>o" "<cmd>NvimTreeFindFile<cr>" "Open current file in NvimTree" )
  ];

}

