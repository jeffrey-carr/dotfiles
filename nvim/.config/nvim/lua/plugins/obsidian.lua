return {
  {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = true,
    ft = "markdown",
    event = {
      "BufReadPre " .. vim.fn.expand("~") .. "/Documents/notes/**.md",
      "BufNewFile " .. vim.fn.expand("~") .. "/Documents/notes/**.md",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      workspaces = {
        {
          name = "notes",
          path = "~/Documents/notes",
        },
      },
      finder = "fzf-lua",
      completion = {
        blink = true,
        nvim_cmp = false,
        min_chars = 2,
      },
      daily_notes = {
        folder = "daily notes",
      },
      attachments = {
        img_folder = "images",
      },
      -- render-markdown.nvim already handles conceal/highlighting
      ui = {
        enable = false,
        checkboxes = {
          [" "] = { order = 1 },
          ["x"] = { order = 2 },
          ["~"] = { order = 3 },
          ["!"] = { order = 4 },
          [">"] = { order = 5 },
        },
      },
    },
    keys = {
      { "<leader>no", "<cmd>ObsidianOpen<cr>", desc = "Open current note in Obsidian app" },
      { "<leader>nf", "<cmd>ObsidianQuickSwitch<cr>", desc = "Find note" },
      { "<leader>ns", "<cmd>ObsidianSearch<cr>", desc = "Search notes" },
      { "<leader>nb", "<cmd>ObsidianBacklinks<cr>", desc = "Show backlinks" },
      { "<leader>nl", "<cmd>ObsidianFollowLink<cr>", desc = "Follow link under cursor" },
      { "<leader>nn", "<cmd>ObsidianNew<cr>", desc = "New note" },
      { "<leader>nd", "<cmd>ObsidianToday<cr>", desc = "Open today's daily note" },
      { "<leader>nr", "<cmd>ObsidianRename<cr>", desc = "Rename note (updates backlinks)" },
      { "<leader>nc", "<cmd>ObsidianToggleCheckbox<cr>", desc = "Toggle checkbox" },
      { "<leader>np", "<cmd>ObsidianPasteImg<cr>", desc = "Paste image" },
      { "<leader>nt", "<cmd>ObsidianTags<cr>", desc = "Browse tags" },
      { "<leader>nk", "<cmd>ObsidianLink<cr>", mode = "v", desc = "Link selection to note" },
      { "<leader>nK", "<cmd>ObsidianLinkNew<cr>", mode = "v", desc = "Link selection to new note" },
    },
  },
}
