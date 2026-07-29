return {
  {
    "Al0den/notion.nvim",
    lazy = false,
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("notion").setup({
        viewOnEdit = {
          enabled = true,
          replace = true -- Replaces current window instead of opening a split
        }
      })
    end,
    keys = {
      { "<leader>no", function() require("notion").openMenu() end, desc = "Open Notion Menu" },
    },
  },
}
