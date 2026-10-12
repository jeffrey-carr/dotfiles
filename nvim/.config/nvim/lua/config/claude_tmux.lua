-- Runs Claude Code in a tmux split pane beside Neovim instead of a Neovim
-- terminal buffer, so the session is owned by tmux and survives Neovim quitting.
-- `M.provider` plugs into claudecode.nvim as a custom terminal provider; the
-- plugin's IDE server (diffs, selection sharing, @-mentions) works the same
-- because the CLI connects to it over the ~/.claude/ide lock file via --ide.
local M = {}

-- `--ide` is required: the pane is spawned by the tmux server, so it never sees
-- the CLAUDE_CODE_SSE_PORT env claudecode would hand an in-editor terminal.
M.cmd = "claude --ide"

local SPLIT_SIZE = "40%"
local FIELDS = {
  "pane_id",
  "window_id",
  "@claude_cwd",
  "pane_current_command",
  "pane_current_path",
  "session_name",
  "window_index",
  "pane_index",
}

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "Claude" })
end

local function in_tmux()
  return vim.env.TMUX ~= nil and vim.env.TMUX_PANE ~= nil
end
M.in_tmux = in_tmux

--- @param args string[]
--- @return string? stdout nil when tmux exits non-zero
local function tmux(args)
  local res = vim.system(vim.list_extend({ "tmux" }, args), { text = true }):wait()
  if res.code ~= 0 then
    return nil
  end
  return vim.trim(res.stdout or "")
end

-- The native installer execs a versioned binary, so tmux reports the running
-- command as e.g. "2.1.282" rather than "claude".
local function is_claude(cmd)
  return cmd == "claude" or cmd:match("^%d+%.%d+%.%d+") ~= nil
end

--- @param scope "-s"|"-a" current session, or every session
local function list_panes(scope)
  local fmt = table.concat(
    vim.tbl_map(function(f)
      return "#{" .. f .. "}"
    end, FIELDS),
    "\t"
  )
  local args = { "list-panes", scope, "-F", fmt }
  if scope == "-s" then
    vim.list_extend(args, { "-t", vim.env.TMUX_PANE })
  end
  local nvim_window = tmux({ "display-message", "-p", "-t", vim.env.TMUX_PANE, "#{window_id}" })
  local panes = {}
  for _, line in ipairs(vim.split(tmux(args) or "", "\n", { trimempty = true })) do
    local f = vim.split(line, "\t", { plain = true })
    table.insert(panes, {
      id = f[1],
      tag = f[3],
      running = is_claude(f[4]),
      path = f[5],
      label = string.format("%s:%s.%s", f[6], f[7], f[8]),
      visible = f[2] == nvim_window,
    })
  end
  return panes
end

--- The pane tagged for `dir` in this tmux session, if any.
local function find(dir)
  for _, p in ipairs(list_panes("-s")) do
    if p.tag == dir then
      return p
    end
  end
end

local function focus(pane)
  tmux({ "select-window", "-t", pane })
  tmux({ "select-pane", "-t", pane })
end

local function hide(pane)
  tmux({ "break-pane", "-d", "-s", pane, "-n", "claude" })
end

local function show(pane, focused)
  local args = { "join-pane", "-h", "-l", SPLIT_SIZE, "-s", pane, "-t", vim.env.TMUX_PANE }
  if not focused then
    table.insert(args, 2, "-d")
  end
  tmux(args)
end

-- Pasted (bracketed, when the app asks for it) rather than typed with
-- send-keys: with Claude's vim editor mode in NORMAL, typed "/resume" runs as
-- vim commands (r-e replaces a char, s enters insert) and only "ume" lands.
-- Enter goes out separately and slightly later so it's a submit, not part of
-- the paste.
local function send(pane, text)
  tmux({ "set-buffer", "-b", "claude-nvim", text })
  tmux({ "paste-buffer", "-d", "-p", "-b", "claude-nvim", "-t", pane })
  vim.defer_fn(function()
    tmux({ "send-keys", "-t", pane, "Enter" })
  end, 100)
end

local function tag(pane, dir)
  tmux({ "set-option", "-p", "-t", pane, "@claude_cwd", dir })
end

-- Typed into the pane's interactive zsh rather than run as the pane command so
-- Claude gets the full .zshrc environment (PATH etc.); exec'd so the split
-- closes when Claude exits instead of leaving a shell behind.
local function launch(pane, cmd)
  send(pane, "exec " .. cmd)
end

local function create(dir, cmd, focused)
  local args = { "split-window", "-h", "-l", SPLIT_SIZE, "-t", vim.env.TMUX_PANE, "-c", dir, "-P", "-F", "#{pane_id}" }
  if not focused then
    table.insert(args, 2, "-d")
  end
  local pane = tmux(args)
  if not pane then
    notify("tmux split-window failed", vim.log.levels.ERROR)
    return
  end
  tag(pane, dir)
  launch(pane, cmd)
end

local function connected()
  local ok, claudecode = pcall(require, "claudecode")
  return ok and claudecode.is_claude_connected()
end

--- Bring the pane beside Neovim (and focus it) without starting anything.
local function reveal(p)
  if p.visible then
    focus(p.id)
  else
    show(p.id, true)
  end
end

local function open(cmd, cfg, focused)
  -- Must match Neovim's cwd: claudecode advertises it as the lock file's
  -- workspace folder, and Claude only lists IDEs whose workspace contains its cwd.
  local dir = (cfg and cfg.cwd) or vim.fn.getcwd()
  local p = find(dir)
  if not p then
    create(dir, cmd, focused)
    return
  end
  if not p.visible then
    show(p.id, focused)
  elseif focused then
    focus(p.id)
  end
  if not p.running then
    launch(p.id, cmd)
  elseif not connected() then
    notify("Claude is running but not connected to this Neovim -- <leader>aR to reconnect", vim.log.levels.WARN)
  end
end

M.provider = {
  setup = function() end,
  is_available = in_tmux,
  get_active_bufnr = function()
    return nil
  end,
  open = function(cmd, _, cfg, focused)
    open(cmd, cfg, focused ~= false)
  end,
  simple_toggle = function(cmd, _, cfg)
    local p = find((cfg and cfg.cwd) or vim.fn.getcwd())
    if p and p.visible then
      hide(p.id)
    else
      open(cmd, cfg, true)
    end
  end,
  -- Called from Neovim, so the Claude pane is never the focused one here.
  focus_toggle = function(cmd, _, cfg)
    open(cmd, cfg, true)
  end,
  -- Hiding only; closing must never kill the session.
  close = function()
    local p = find(vim.fn.getcwd())
    if p and p.visible then
      hide(p.id)
    end
  end,
  -- Runs after every send. Re-shows a hidden pane but never creates one.
  ensure_visible = function()
    local p = find(vim.fn.getcwd())
    if p and not p.visible then
      show(p.id, false)
    end
  end,
}

function M.new()
  if not in_tmux() then
    return vim.cmd("ClaudeCodeOpen")
  end
  local p = find(vim.fn.getcwd())
  if p and p.running then
    reveal(p)
    -- Starts a fresh conversation; the previous one stays available to /resume.
    send(p.id, "/clear")
  else
    open(M.cmd, nil, true)
  end
end

function M.resume()
  if not in_tmux() then
    return vim.cmd("ClaudeCodeOpen --resume")
  end
  local p = find(vim.fn.getcwd())
  if p and p.running then
    reveal(p)
    send(p.id, "/resume")
  else
    open(M.cmd .. " --resume", nil, true)
  end
end

function M.continue()
  if not in_tmux() then
    return vim.cmd("ClaudeCodeOpen --continue")
  end
  local p = find(vim.fn.getcwd())
  if p and p.running then
    reveal(p)
    notify("Claude is already running here")
  else
    open(M.cmd .. " --continue", nil, true)
  end
end

--- Re-link the pane after Neovim restarts: the IDE server comes back on a new
--- port with a new auth token, and the running CLI has to rediscover it.
function M.reconnect()
  if not in_tmux() then
    return notify("Not inside tmux", vim.log.levels.WARN)
  end
  local p = find(vim.fn.getcwd())
  if not (p and p.running) then
    return notify("No running Claude pane for " .. vim.fn.getcwd(), vim.log.levels.WARN)
  end
  reveal(p)
  send(p.id, "/ide")
end

--- Pull a Claude that's already running in any tmux pane (any session) in
--- beside this Neovim and link it.
function M.attach()
  if not in_tmux() then
    return notify("Not inside tmux", vim.log.levels.WARN)
  end
  local dir = vim.fn.getcwd()
  local candidates = vim.tbl_filter(function(p)
    return p.running and p.id ~= vim.env.TMUX_PANE
  end, list_panes("-a"))
  if #candidates == 0 then
    return notify("No running Claude sessions found in tmux", vim.log.levels.WARN)
  end

  vim.ui.select(candidates, {
    prompt = "Attach Claude session",
    format_item = function(p)
      return string.format("%s  %s%s", p.label, vim.fn.fnamemodify(p.path, ":~"), p.tag == dir and "  (linked)" or "")
    end,
  }, function(choice)
    if not choice then
      return
    end
    if choice.path ~= dir and not vim.startswith(choice.path, dir .. "/") then
      notify(
        "That Claude runs in " .. choice.path .. ", outside " .. dir .. " -- /ide won't list this Neovim",
        vim.log.levels.WARN
      )
    end
    local current = find(dir)
    if current and current.id ~= choice.id then
      tmux({ "set-option", "-p", "-u", "-t", current.id, "@claude_cwd" })
    end
    tag(choice.id, dir)
    reveal(choice)
    send(choice.id, "/ide")
  end)
end

function M.setup()
  local group = vim.api.nvim_create_augroup("ClaudeTmux", { clear = true })

  -- Follow Claude's proposed edits: jump to the Neovim pane when a diff opens,
  -- and back to Claude once it's resolved. Each jump only happens if you're
  -- still where the previous one left you, so a diff never yanks focus from
  -- some other pane you've moved to.
  local function is_active(pane)
    return tmux({ "display-message", "-p", "-t", pane, "#{window_active}#{pane_active}" }) == "11"
  end
  local jumped_from
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "ClaudeCodeDiffOpened",
    callback = function()
      if not in_tmux() then
        return
      end
      local p = find(vim.fn.getcwd())
      if p and is_active(p.id) then
        jumped_from = p.id
        focus(vim.env.TMUX_PANE)
      end
    end,
  })
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "ClaudeCodeDiffClosed",
    callback = function()
      vim.cmd("checktime")
      if jumped_from and is_active(vim.env.TMUX_PANE) then
        focus(jumped_from)
      end
      jumped_from = nil
    end,
  })

  -- Neovim is unfocused while you type in the Claude pane, so FocusGained and
  -- CursorHold never fire; poll so edits Claude writes directly (auto-accept
  -- mode) show up live. Skipped outside plain normal mode so a reload prompt
  -- can't land mid-insert or mid-command.
  local timer = vim.uv.new_timer()
  timer:start(
    1000,
    1000,
    vim.schedule_wrap(function()
      local mode = vim.api.nvim_get_mode().mode
      if (mode == "n" or mode == "nt") and vim.fn.getcmdwintype() == "" then
        vim.cmd("checktime")
      end
    end)
  )

  pcall(function()
    require("which-key").add({ { "<leader>a", group = "AI / Claude" } })
  end)
end

return M
