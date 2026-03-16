return {
  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
    },
  },

  -- Neo-tree (High-polish Explorer)
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle Explorer" },
    },
    opts = {
      filesystem = {
        filtered_items = { show_hidden = true },
        follow_current_file = { enabled = true },
      },
      window = {
        width = 30,
        mappings = {
          ["<space>"] = "none",
        },
      },
    }
  },

  -- UI Improvements (Nicer inputs and selects)
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    opts = {},
  },

  -- Leap (Cursor movement)
  {
    url = "https://codeberg.org/andyg/leap.nvim",
    config = function()
      -- The method name has been updated to add_default_mappings
      require('leap').add_default_mappings()
      -- The <Plug>(leap-from-window) mapping is bound to 'S' in config/keymaps.lua
    end,
  },

  -- Trouble (Diagnostics list)
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
    },
    opts = {},
  },

  -- Which-Key (Keybind hints)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  },

  -- WindowSwap
  {
    "wesQ3/vim-windowswap",
    keys = {
      { "<leader>yw", "<cmd>call WindowSwap#MarkWindowSwap()<CR>", desc = "Yank window for swap" },
      { "<leader>pw", "<cmd>call WindowSwap#DoWindowSwap()<CR>", desc = "Paste window swap" },
    }
  },

  -- Cellular Automaton
  {
    "Eandrju/cellular-automaton.nvim",
    keys = {
      { "<leader>fml", "<cmd>CellularAutomaton make_it_rain<CR>", desc = "Make it rain" },
    }
  },

  -- Goto Preview
  {
    "rmagatti/goto-preview",
    keys = {
      { "gpd", "<cmd>lua require('goto-preview').goto_preview_definition()<CR>", desc = "Preview Definition" },
      { "gpt", "<cmd>lua require('goto-preview').goto_preview_type_definition()<CR>", desc = "Preview Type Def" },
      { "gpi", "<cmd>lua require('goto-preview').goto_preview_implementation()<CR>", desc = "Preview Implementation" },
      { "gP", "<cmd>lua require('goto-preview').close_all_win()<CR>", desc = "Close All Previews" },
    },
    config = function()
      require('goto-preview').setup {}
    end
  }
}