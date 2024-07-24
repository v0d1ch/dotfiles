{mkKey,...}:
let
  inherit (mkKey) mkKeymap;
in {
  plugins.telescope = {
    enable = true;
    extensions = {
      fzf-native.enable = true;
      undo.enable = true;
    };
    settings = {
      pickers = {
        colorscheme.enable_preview = true;
      };
      defaults.mappings = {
        n = {
          q = {
            __raw = "require('telescope.actions').close";
          };
          s = {
            __raw = "require('telescope.actions').select_horizontal";
          };
          v = {
            __raw = "require('telescope.actions').select_vertical";
          };
        };
      };
    };
  };
  keymaps = [
    (mkKeymap "n" "<leader>f" "<cmd>Telescope find_files<cr>" "Search Find files" )
    (mkKeymap "n" "<leader>rs" "<cmd>Telescope resume<cr>" "Search Find files" )
    (mkKeymap "n" "<leader>s" "<cmd>Telescope grep_string<cr>" "Search Find files" )
    (mkKeymap "n" "<leader>b" "<cmd>Telescope buffers<cr>" "Search Find files" )
    (mkKeymap "n" "<leader>k" "<cmd>Telescope current_buffer_fuzzy_find<cr>" "Fuzzy Buffer Search" )
 
  ];
}
