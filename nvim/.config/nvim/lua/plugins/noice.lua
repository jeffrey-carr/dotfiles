return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    opts = {
      -- Tell Noice to use Snacks for notifications
      notify = {
        enabled = false,
      },
      lsp = {
        -- The floating "mini" progress popup refreshes every 100ms while an LSP
        -- server reports progress (e.g. gopls indexing), independent of cursor
        -- movement. Its window churn is a likely source of visible cursor
        -- jumping if it happens to overlap with scrolling.
        progress = {
          enabled = false,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
        -- Rounded border for hover/signature-help popups, now that they're
        -- rendered by Noice again instead of a manually-bordered vanilla float.
        lsp_doc_border = true,
      },
      cmdline = {
        format = {
          cmdline = { icon = "" },
          search_down = { icon = "󰄼" },
          search_up = { icon = "󰄽" },
          filter = { icon = "" },
          lua = { icon = "" },
          help = { icon = "󰋖" },
          input = { icon = "" },
        },
      },
    },
  }
}
