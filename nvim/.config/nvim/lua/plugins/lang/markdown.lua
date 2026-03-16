return {
  -- Update Mason with Markdown LSP
  {
    "williamboman/mason-lspconfig.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "marksman" })
    end,
  },

  -- Setup Markdown LSP
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        marksman = {}
      }
    }
  },
}