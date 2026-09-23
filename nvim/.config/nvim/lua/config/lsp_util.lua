-- Shared helpers for keeping LSP clients off of buffers that aren't real
-- files on disk (diffview://, fugitive://, etc.). Nvim's vim.uri_from_bufnr()
-- sends such buffer names to the server *unchanged* instead of wrapping them
-- in file://, which is what makes servers like gopls reject them with
-- "-32700 DocumentURI scheme is not 'file'".
local M = {}

local URI_SCHEME_PATTERN = "^([a-zA-Z][a-zA-Z0-9.+-]*):.*"

--- @param bufnr integer
--- @return boolean
function M.is_non_file_buf(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  local scheme = name:match(URI_SCHEME_PATTERN)
  return scheme ~= nil and scheme ~= "file"
end

--- Wrap a modern `vim.lsp.Config.root_dir` (the `function(bufnr, on_dir)`
--- shape) so it refuses to resolve a root -- and therefore refuses to let
--- the client ever start (see lsp_enable_callback in runtime/lua/vim/lsp.lua)
--- -- for buffers that aren't real files on disk.
--- @param root_dir fun(bufnr: integer, on_dir: fun(root: string?))
--- @return fun(bufnr: integer, on_dir: fun(root: string?))
function M.guard_root_dir(root_dir)
  return function(bufnr, on_dir)
    if M.is_non_file_buf(bufnr) then
      return -- never call on_dir(): client never attaches to this buffer
    end
    return root_dir(bufnr, on_dir)
  end
end

--- Detach a client that has attached to a non-file buffer. Must be deferred:
--- Client:on_attach() only sets attached_buffers[bufnr] *after* the LspAttach
--- autocmd finishes running, and vim.lsp.buf_detach_client() is a silent
--- no-op if attached_buffers[bufnr] isn't set yet.
--- @param bufnr integer
--- @param client_id integer
function M.detach_deferred(bufnr, client_id)
  vim.schedule(function()
    if vim.lsp.buf_is_attached(bufnr, client_id) then
      vim.lsp.buf_detach_client(bufnr, client_id)
    end
  end)
end

-- Baseline gopls inlay hints: only the ones useful while calling a function
-- or reading a loop/constant, not on every plain variable or struct literal.
M.gopls_hints_minimal = {
  assignVariableTypes = false,
  compositeLiteralFields = false,
  compositeLiteralTypes = false,
  constantValues = true,
  functionTypeParameters = false,
  parameterNames = true,
  rangeVariableTypes = true,
}

-- All gopls hint categories, for the "show everything" toggle.
M.gopls_hints_full = {
  assignVariableTypes = true,
  compositeLiteralFields = true,
  compositeLiteralTypes = true,
  constantValues = true,
  functionTypeParameters = true,
  parameterNames = true,
  rangeVariableTypes = true,
}

--- Toggle the attached gopls client for `bufnr` between M.gopls_hints_minimal
--- and M.gopls_hints_full. The flag is buffer-local, but gopls.settings is
--- shared by every buffer the client covers (typically one client per Go
--- module), so switching from one buffer affects hints in all of them.
--- @param bufnr integer
function M.toggle_gopls_full_hints(bufnr)
  local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "gopls" })
  local client = clients[1]
  if not client then
    vim.notify("toggle_gopls_full_hints: no gopls client attached", vim.log.levels.WARN)
    return
  end

  local full = not vim.b[bufnr].gopls_full_hints
  vim.b[bufnr].gopls_full_hints = full

  client.settings = client.settings or {}
  client.settings.gopls = client.settings.gopls or {}
  client.settings.gopls.hints = full and M.gopls_hints_full or M.gopls_hints_minimal
  client:notify("workspace/didChangeConfiguration", { settings = vim.empty_dict() })

  vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
  vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })

  vim.notify("gopls hints: " .. (full and "full" or "minimal"))
end

return M
