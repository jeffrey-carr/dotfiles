-- On save, only touch lines actually changed since the last commit. This repo has no
-- shared Python formatter/lint config, so a whole-buffer format or autofix would rewrite
-- teammates' code under whatever style/rules happen to be configured locally, creating
-- unrelated diff noise. Mirrors VS Code's "Format on Save: Modifications" behavior.
local function ruff_code_action(bufnr, only, range)
  local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "ruff" })
  if #clients == 0 then
    return
  end
  local client = clients[1]
  if not range then
    local last_row = vim.api.nvim_buf_line_count(bufnr)
    local last_line = vim.api.nvim_buf_get_lines(bufnr, last_row - 1, last_row, true)[1] or ""
    range = { start_row = 1, end_row = last_row, end_col = #last_line }
  end
  local params = {
    textDocument = vim.lsp.util.make_text_document_params(bufnr),
    range = {
      start = { line = range.start_row - 1, character = 0 },
      ["end"] = { line = range.end_row - 1, character = range.end_col },
    },
    context = { only = only, diagnostics = {} },
  }
  local result = vim.lsp.buf_request_sync(bufnr, "textDocument/codeAction", params, 1000)
  for _, res in pairs(result or {}) do
    for _, action in pairs(res.result or {}) do
      if action.edit then
        vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
      elseif action.command then
        vim.lsp.buf.execute_command(action.command)
      end
    end
  end
end

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.py",
  callback = function(args)
    local bufnr = args.buf

    -- Organize imports always acts on the import block regardless of what else changed —
    -- narrow and low-risk, matching VS Code's "Organize Imports" behavior.
    ruff_code_action(bufnr, { "source.organizeImports.ruff" })

    local ok, gitsigns = pcall(require, "gitsigns")
    if not ok then
      return
    end
    local hunks = gitsigns.get_hunks(bufnr)
    if not hunks then
      return
    end

    for _, hunk in ipairs(hunks) do
      if hunk.added and hunk.added.count > 0 then
        local start_row = hunk.added.start
        local end_row = hunk.added.start + hunk.added.count - 1
        local end_line = vim.api.nvim_buf_get_lines(bufnr, end_row - 1, end_row, true)[1] or ""

        ruff_code_action(bufnr, { "source.fixAll.ruff" }, {
          start_row = start_row,
          end_row = end_row,
          end_col = #end_line,
        })

        require("conform").format({
          bufnr = bufnr,
          range = { ["start"] = { start_row, 0 }, ["end"] = { end_row, #end_line } },
          lsp_fallback = true,
        })
      end
    end
  end,
})

return {
  -- Add pyright and ruff to Mason-managed LSP servers
  {
    "williamboman/mason-lspconfig.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "pyright", "ruff" })
    end,
  },

  -- Add ruff CLI to Mason (used directly by conform's ruff_format formatter)
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "ruff" })
    end,
  },

  -- Configure pyright (types/completion/hover) and ruff (lint diagnostics/quick-fixes)
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "basic",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                inlayHints = {
                  variableTypes = true,
                  callArgumentNames = true,
                  functionReturnTypes = true,
                  pytestParameters = true,
                },
              },
            },
          },
        },
        ruff = {
          on_attach = function(client)
            -- Let pyright own hover; ruff only contributes diagnostics/code actions
            client.server_capabilities.hoverProvider = false
          end,
        },
      },
    },
  },

  -- Add ruff formatting for Python files
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.python = { "ruff_format" }
    end,
  },

  -- Venv/interpreter picker (updates pyright & ruff to use the selected venv)
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = { "neovim/nvim-lspconfig" },
    ft = "python",
    opts = {
      options = {
        picker = "fzf-lua",
      },
    },
    keys = {
      { "<leader>vs", "<cmd>VenvSelect<cr>", desc = "Select Python venv" },
    },
  },
}
