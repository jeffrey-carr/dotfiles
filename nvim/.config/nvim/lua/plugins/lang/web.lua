return {
  -- Update Mason with Web LSPs
  {
    "williamboman/mason-lspconfig.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "html", "cssls", "svelte" })
    end,
  },

  -- Setup Web LSPs
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        html = {},
        cssls = {},
        svelte = {}
      }
    }
  },
}