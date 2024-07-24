{mkKey,...}:
let
  inherit (mkKey) mkKeymap;
in {
  plugins.project-nvim = {
    enable = true;
  };
  keymaps = [
      (mkKeymap "n" "<leader>p" "<cmd>Telescope projects<cr>" "Select a project" )
  ];
}
