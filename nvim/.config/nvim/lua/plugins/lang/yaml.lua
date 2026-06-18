return {
  -- Update Mason with YAML LSP
  {
    "williamboman/mason-lspconfig.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "yamlls" })
    end,
  },

  -- Setup YAML LSP
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        yamlls = {
          -- Additional settings can be customized here
          settings = {
            yaml = {
              keyOrdering = false,
            },
          },
        },
      },
    },
  },
}
