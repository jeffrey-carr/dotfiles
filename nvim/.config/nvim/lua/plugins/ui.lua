return {
  -- Bufferline (Tabs/Buffers)
  {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    version = "*",
    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers",
          diagnostics = "nvim_lsp",
          always_show_bufferline = true,
        },
      })
    end,
  },

  -- Indent Guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {},
  },

  -- Modern Notifications
  {
    "rcarriga/nvim-notify",
    config = function()
      local notify = require("notify")
      notify.setup({
        background_colour = "#000000",
      })
      vim.notify = notify
    end,
  },

  -- Smooth cursor animations
  {
    "sphamba/smear-cursor.nvim",
    opts = {},
  },

  -- Scrollbar
  {
    "lewis6991/satellite.nvim",
    config = function()
      require('satellite').setup()
    end,
  },

  -- Markdown Preview
  {
    "OXY2DEV/markview.nvim",
    lazy = false,      -- Recommended
  },

  -- Code Snapshots
  {
    "mistricky/codesnap.nvim",
    build = "make",
    keys = {
      { "<leader>cc", "<cmd>CodeSnap<cr>", mode = "x", desc = "Save selected code snapshot" },
    },
  },
}