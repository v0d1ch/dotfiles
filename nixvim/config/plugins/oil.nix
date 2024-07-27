{mkKey,...}:
let
  inherit (mkKey) mkKeymap;
in {
  plugins.oil = {
    enable = true;
    settings = {
      delete_to_trash = true;
      use_default_keymaps = true;
      lsp_file_method.autosave_changes = true;
      buf_options = {
        buflisted = true;
        bufhidden = "hide";
      };
      view_options = {
        show_hidden = true;
      };
    };
  };

  keymaps = [
    (mkKeymap "n" "<leader>o" "<cmd>Oil<cr>" "Open current file in Oil" )
  ];
}
