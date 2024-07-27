{ 
  plugins.obsidian = {
    enable = true;
    settings = {
      completion = {
        min_chars = 2;
        nvim_cmp = true;
      };
      workspaces = [
        {
          name = "v0d1ch";
          path = "~/Documents/v0d1ch";
        }
      ];
      mappings = {
        tf = {
          action = "require('obsidian').util.gf_passthrough";
          opts = {
            noremap = false;
            expr = true;
            buffer = true;
          };
        };
      };
    };
  };
}
