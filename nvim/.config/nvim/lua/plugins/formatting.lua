return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>fm",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        mode = "",
        desc = "Format buffer",
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        go = { "goimports", "gofmt" },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "prettierd", "prettier", stop_after_first = true },
        svelte = { "prettierd", "prettier", stop_after_first = true },
        html = { "prettierd", "prettier", stop_after_first = true },
        css = { "prettierd", "prettier", stop_after_first = true },
        scss = { "prettierd", "prettier", stop_after_first = true },
        markdown = { "prettierd", "prettier", stop_after_first = true },
        json = { "prettierd", "prettier", stop_after_first = true },
      },
      format_on_save = function(bufnr)
        -- Python has no shared formatter/lint config across the team, so a whole-buffer
        -- format-on-save here would rewrite teammates' code under a different style.
        -- Skip it; lua/plugins/lang/python.lua formats only the lines actually changed.
        if vim.bo[bufnr].filetype == "python" then
          return nil
        end
        return {
          timeout_ms = 500,
          lsp_fallback = true,
        }
      end,
    },
  },
}