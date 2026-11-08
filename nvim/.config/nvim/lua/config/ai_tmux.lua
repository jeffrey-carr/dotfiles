-- Runs an AI coding CLI (Claude Code, Antigravity, ...) in a tmux split pane beside
-- Neovim instead of a Neovim terminal buffer, so the session is owned by tmux and
-- survives Neovim quitting.
--
-- Which CLI: $AI_CLI if set (a key of CLIS below), otherwise the first CLI in ORDER
-- that is installed. Each CLI lists what it supports; a key for something it lacks
-- shows a notice instead.
--
-- For Claude, `M.provider` also plugs into claudecode.nvim as a custom terminal
-- provider; the plugin's IDE server (diffs, selection sharing, @-mentions) works the
-- same because the CLI connects to it over the ~/.claude/ide lock file via --ide.
local M = {}

local WARN = vim.log.levels.WARN

---@class AiCli
---@field name string            shown in messages and as the hidden pane's window name
---@field cmd string             command that starts the CLI
---@field is_running fun(cmd: string): boolean  matches tmux's #{pane_current_command}
---@field new_slash? string      typed into a running CLI to start a fresh conversation
---@field resume_slash? string   typed into a running CLI to pick a conversation to resume
---@field resume_flag? string    added to `cmd` to start the CLI on its resume picker
---@field continue_flag? string  added to `cmd` to continue the most recent conversation
---@field ide? boolean           speaks Claude Code's IDE protocol (claudecode.nvim, /ide)

---@type table<string, AiCli>
local CLIS = {
  claude = {
    name = "Claude",
    -- `--ide` is required: the pane is spawned by the tmux server, so it never sees
    -- the CLAUDE_CODE_SSE_PORT env claudecode would hand an in-editor terminal.
    cmd = "claude --ide",
    -- The native installer execs a versioned binary, so tmux reports the running
    -- command as e.g. "2.1.282" rather than "claude".
    is_running = function(cmd)
      return cmd == "claude" or cmd:match("^%d+%.%d+%.%d+") ~= nil
    end,
    new_slash = "/clear",
    resume_slash = "/resume",
    resume_flag = "--resume",
    continue_flag = "--continue",
    ide = true,
  },
  agy = {
    name = "Antigravity",
    cmd = "agy",
    is_running = function(cmd)
      return cmd == "agy"
    end,
    -- agy has no resume picker (only --conversation <id>). Add new_slash/resume_slash
    -- here if it has slash commands for those.
    continue_flag = "--continue",
  },
}
local ORDER = { "claude", "agy" }

--- @return string? key, AiCli? cli
local function pick()
  local want = vim.env.AI_CLI
  if want and want ~= "" then
    if CLIS[want] then
      return want, CLIS[want]
    end
    vim.schedule(function()
      vim.notify(
        string.format("AI_CLI=%s is not one of: %s", want, table.concat(ORDER, ", ")),
        WARN,
        { title = "AI" }
      )
    end)
  end
  for _, key in ipairs(ORDER) do
    if vim.fn.executable(CLIS[key].cmd:match("^%S+")) == 1 then
      return key, CLIS[key]
    end
  end
end

M.key, M.cli = pick()
M.cmd = M.cli and M.cli.cmd
--- True when the selected CLI speaks Claude Code's IDE protocol (see plugins/ai.lua).
M.ide = M.cli ~= nil and M.cli.ide == true

local SPLIT_SIZE = "40%"
local TAG = "@ai_cwd"
local FIELDS = {
  "pane_id",
  "window_id",
  TAG,
  "pane_current_command",
  "pane_current_path",
  "session_name",
  "window_index",
  "pane_index",
}

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = M.cli and M.cli.name or "AI" })
end

--- Notifies when no CLI was found; returns true when one was.
local function have_cli()
  if not M.cli then
    notify("No AI CLI found (looked for " .. table.concat(ORDER, ", ") .. ")", WARN)
  end
  return M.cli ~= nil
end

local function unsupported(what)
  notify(M.cli.name .. " does not support " .. what, WARN)
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
      running = M.cli ~= nil and M.cli.is_running(f[4]),
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
  tmux({ "break-pane", "-d", "-s", pane, "-n", M.cli.name:lower() })
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
  tmux({ "set-buffer", "-b", "ai-nvim", text })
  tmux({ "paste-buffer", "-d", "-p", "-b", "ai-nvim", "-t", pane })
  vim.defer_fn(function()
    tmux({ "send-keys", "-t", pane, "Enter" })
  end, 100)
end

local function tag(pane, dir)
  tmux({ "set-option", "-p", "-t", pane, TAG, dir })
end

-- Typed into the pane's interactive zsh rather than run as the pane command so
-- the CLI gets the full .zshrc environment (PATH etc.); exec'd so the split
-- closes when the CLI exits instead of leaving a shell behind.
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
  elseif M.ide and not connected() then
    notify(M.cli.name .. " is running but not connected to this Neovim -- <leader>aR to reconnect", WARN)
  end
end

local function toggle(cmd, cfg)
  local p = find((cfg and cfg.cwd) or vim.fn.getcwd())
  if p and p.visible then
    hide(p.id)
  else
    open(cmd, cfg, true)
  end
end

--- Without tmux: Claude falls back to claudecode's own terminal, other CLIs to a
--- Snacks terminal split.
--- @param flag string? added to the CLI command
--- @param claudecode_cmd string? claudecode command to use instead of ClaudeCodeOpen
local function outside_tmux(flag, claudecode_cmd)
  if M.ide then
    return vim.cmd((claudecode_cmd or "ClaudeCodeOpen") .. (flag and (" " .. flag) or ""))
  end
  Snacks.terminal.toggle(M.cmd .. (flag and (" " .. flag) or ""), { win = { position = "right", width = 0.4 } })
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
    toggle(cmd, cfg)
  end,
  -- Called from Neovim, so the AI pane is never the focused one here.
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

--- Show or hide the pane for Neovim's cwd, starting the CLI if it isn't running.
function M.toggle()
  if not have_cli() then
    return
  end
  if not in_tmux() then
    return outside_tmux(nil, "ClaudeCode")
  end
  toggle(M.cmd)
end

--- Show and focus the pane, starting the CLI if it isn't running.
function M.focus()
  if not have_cli() then
    return
  end
  if not in_tmux() then
    return outside_tmux(nil, "ClaudeCodeFocus")
  end
  open(M.cmd, nil, true)
end

function M.new()
  if not have_cli() then
    return
  end
  if not in_tmux() then
    return outside_tmux()
  end
  local p = find(vim.fn.getcwd())
  if not (p and p.running) then
    return open(M.cmd, nil, true)
  end
  if not M.cli.new_slash then
    return unsupported("starting a new conversation in a running session")
  end
  reveal(p)
  -- Starts a fresh conversation; the previous one stays available to resume.
  send(p.id, M.cli.new_slash)
end

function M.resume()
  if not have_cli() then
    return
  end
  if not (M.cli.resume_slash or M.cli.resume_flag) then
    return unsupported("a resume picker")
  end
  if not in_tmux() then
    return outside_tmux(M.cli.resume_flag)
  end
  local p = find(vim.fn.getcwd())
  if p and p.running then
    if not M.cli.resume_slash then
      return unsupported("resuming from a running session")
    end
    reveal(p)
    send(p.id, M.cli.resume_slash)
  elseif M.cli.resume_flag then
    open(M.cmd .. " " .. M.cli.resume_flag, nil, true)
  else
    unsupported("starting on a resume picker")
  end
end

function M.continue()
  if not have_cli() then
    return
  end
  if not M.cli.continue_flag then
    return unsupported("continuing the last conversation")
  end
  if not in_tmux() then
    return outside_tmux(M.cli.continue_flag)
  end
  local p = find(vim.fn.getcwd())
  if p and p.running then
    reveal(p)
    notify(M.cli.name .. " is already running here")
  else
    open(M.cmd .. " " .. M.cli.continue_flag, nil, true)
  end
end

--- Re-link the pane after Neovim restarts: the IDE server comes back on a new
--- port with a new auth token, and the running CLI has to rediscover it.
function M.reconnect()
  if not have_cli() then
    return
  end
  if not M.ide then
    return unsupported("the IDE link (/ide)")
  end
  if not in_tmux() then
    return notify("Not inside tmux", WARN)
  end
  local p = find(vim.fn.getcwd())
  if not (p and p.running) then
    return notify("No running " .. M.cli.name .. " pane for " .. vim.fn.getcwd(), WARN)
  end
  reveal(p)
  send(p.id, "/ide")
end

--- Send a prompt (e.g. a slash command) to the AI pane for Neovim's cwd. Only
--- sends to a CLI that's already running: a freshly launched one isn't ready
--- to take input for a few seconds.
function M.prompt(text)
  if not have_cli() then
    return
  end
  if not in_tmux() then
    return notify("Not inside tmux -- run " .. text .. " in " .. M.cli.name .. " yourself", WARN)
  end
  local p = find(vim.fn.getcwd())
  if not (p and p.running) then
    return notify("No " .. M.cli.name .. " running here -- start it with <leader>ac, then try again", WARN)
  end
  reveal(p)
  send(p.id, text)
end

--- Pull a session that's already running in any tmux pane (any session) in
--- beside this Neovim and link it.
function M.attach()
  if not have_cli() then
    return
  end
  if not in_tmux() then
    return notify("Not inside tmux", WARN)
  end
  local dir = vim.fn.getcwd()
  local candidates = vim.tbl_filter(function(p)
    return p.running and p.id ~= vim.env.TMUX_PANE
  end, list_panes("-a"))
  if #candidates == 0 then
    return notify("No running " .. M.cli.name .. " sessions found in tmux", WARN)
  end

  vim.ui.select(candidates, {
    prompt = "Attach " .. M.cli.name .. " session",
    format_item = function(p)
      return string.format("%s  %s%s", p.label, vim.fn.fnamemodify(p.path, ":~"), p.tag == dir and "  (linked)" or "")
    end,
  }, function(choice)
    if not choice then
      return
    end
    if M.ide and choice.path ~= dir and not vim.startswith(choice.path, dir .. "/") then
      notify(
        "That " .. M.cli.name .. " runs in " .. choice.path .. ", outside " .. dir .. " -- /ide won't list this Neovim",
        WARN
      )
    end
    local current = find(dir)
    if current and current.id ~= choice.id then
      tmux({ "set-option", "-p", "-u", "-t", current.id, TAG })
    end
    tag(choice.id, dir)
    reveal(choice)
    if M.ide then
      send(choice.id, "/ide")
    end
  end)
end

function M.setup()
  local name = M.cli and M.cli.name or "AI"
  local function map(lhs, fn, desc)
    vim.keymap.set("n", lhs, fn, { desc = desc })
  end
  map("<leader>ac", M.toggle, "Toggle " .. name .. " pane")
  map("<leader>af", M.focus, "Focus " .. name)
  map("<leader>an", M.new, "New " .. name .. " conversation")
  map("<leader>ar", M.resume, "Resume " .. name .. " conversation")
  map("<leader>aC", M.continue, "Continue last " .. name .. " conversation")
  map("<leader>ap", M.attach, "Pull in a running " .. name .. " session")

  local group = vim.api.nvim_create_augroup("AiTmux", { clear = true })

  -- which-key loads lazily; register the group once it's there.
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "VeryLazy",
    once = true,
    callback = function()
      pcall(function()
        require("which-key").add({ { "<leader>a", group = "AI / " .. name } })
      end)
    end,
  })

  if not M.cli then
    return
  end

  if M.ide then
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
  end

  -- Neovim is unfocused while you type in the AI pane, so FocusGained and
  -- CursorHold never fire; poll so edits the CLI writes directly show up live.
  -- Skipped outside plain normal mode so a reload prompt can't land mid-insert
  -- or mid-command.
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
end

return M
