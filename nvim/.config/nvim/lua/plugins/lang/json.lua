return {
  -- Update Mason with JSON LSP
  {
    "williamboman/mason-lspconfig.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "jsonls" })
    end,
  },

  -- Setup JSON LSP
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        jsonls = {}
      }
    }
  },
}