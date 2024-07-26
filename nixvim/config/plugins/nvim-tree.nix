{mkKey,...}:
let
  inherit (mkKey) mkKeymap;
in {

  plugins.nvim-tree = { 
        enable = true;
  };

  keymaps = [
    (mkKeymap "n" "<leader>o" "<cmd>NvimTreeFindFile<cr>" "Open current file in NvimTree" )
  ];

}

