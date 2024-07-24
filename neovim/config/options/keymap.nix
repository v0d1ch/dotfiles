{self, ...}: {
  keymaps = [
    {
      mode = "i";
      key = "jk";
      action = "<Esc>";
      options = {
        desc = "jk to escape";
      };
    }
    {
      mode = "n";
      key = "<leader>g";
      action = "<cmd>Neogit<cr>";
      options = {
        desc = "Open Neogit";
      };
    }
    {
      mode = "n";
      key = "<leader>n";
      action = "<cmd>:NvimTreeToggle<cr>";
      options = {
        desc = "NvimTree toggle";
      };
    }

  ];
}
