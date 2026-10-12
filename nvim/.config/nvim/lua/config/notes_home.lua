-- Generates the link section at the top of the notes vault's Home.md. The Obsidian app
-- renders Bases and Tasks blocks live, but Neovim only shows them as code, so this writes
-- the same overview as plain [[wikilinks]] that work in both editors.
local M = {}

M.vault = vim.fn.expand("~/Documents/notes")
M.home = M.vault .. "/Home.md"

local START = "<!-- home:start -->"
local FINISH = "<!-- home:end -->"

-- Daily notes before this date carried task lists copied forward day to day, so their
-- unchecked boxes aren't real stragglers.
local SYSTEM_START = "2026-10-10"

local function read_lines(path)
	local f = io.open(path, "r")
	if not f then
		return nil
	end
	local lines = {}
	for line in f:lines() do
		lines[#lines + 1] = line
	end
	f:close()
	return lines
end

local function stem(path)
	return vim.fn.fnamemodify(path, ":t:r")
end

local function md_files(root)
	local files = {}
	if vim.fn.isdirectory(root) == 0 then
		return files
	end
	for name, kind in vim.fs.dir(root, { depth = 10 }) do
		if kind == "file" and name:match("%.md$") then
			files[#files + 1] = root .. "/" .. name
		end
	end
	table.sort(files)
	return files
end

-- Only the flat `key: value` fields the overview needs; list values are ignored.
local function frontmatter(lines)
	local fields = {}
	if not lines or lines[1] ~= "---" then
		return fields
	end
	for i = 2, #lines do
		local line = lines[i]
		if line == "---" then
			break
		end
		local key, value = line:match("^([%w_]+):%s*(.-)%s*$")
		if key and value ~= "" then
			fields[key] = (value:gsub("^[\"']", ""):gsub("[\"']$", ""))
		end
	end
	return fields
end

-- Counts open checkboxes: `[ ]` plus obsidian.nvim's `[!]` (important). `on_task`, if
-- given, is called with the most recent `## ` heading for each one. Fenced code is
-- skipped so example tasks in docs don't count.
local function count_open_tasks(lines, on_task)
	local total, section, in_fence = 0, nil, false
	for _, line in ipairs(lines or {}) do
		if line:match("^%s*```") or line:match("^%s*~~~") then
			in_fence = not in_fence
		elseif not in_fence then
			section = line:match("^## (.+)") or section
			if line:match("^%s*[-*+] %[[ !]%]") then
				total = total + 1
				if on_task then
					on_task(section)
				end
			end
		end
	end
	return total
end

local function plural(n, word)
	return n .. " " .. word .. (n == 1 and "" or "s")
end

local function links(paths)
	local out = {}
	for _, path in ipairs(paths) do
		out[#out + 1] = "[[" .. stem(path) .. "]]"
	end
	return table.concat(out, " · ")
end

function M.build()
	local out = {}
	local function add(line)
		out[#out + 1] = line
	end

	local today = os.date("%Y-%m-%d")
	local dailies = {}
	for _, path in ipairs(md_files(M.vault .. "/daily notes")) do
		if stem(path):match("^%d%d%d%d%-%d%d%-%d%d$") then
			dailies[#dailies + 1] = path
		end
	end

	if vim.fn.filereadable(M.vault .. "/daily notes/" .. today .. ".md") == 1 then
		add("- **Today:** [[" .. today .. "]]")
	else
		add("- **Today:** no note yet (`<leader>nd`)")
	end

	local per_section, order = {}, {}
	count_open_tasks(read_lines(M.vault .. "/backlog.md"), function(section)
		section = section or "Backlog"
		if not per_section[section] then
			per_section[section] = 0
			order[#order + 1] = section
		end
		per_section[section] = per_section[section] + 1
	end)
	local backlog = {}
	for _, section in ipairs(order) do
		backlog[#backlog + 1] = section .. " " .. per_section[section]
	end
	add("- **Backlog:** [[backlog]]" .. (#backlog > 0 and (": " .. table.concat(backlog, ", ")) or ""))

	local inbox = md_files(M.vault .. "/inbox")
	add("- **Inbox:** " .. (#inbox > 0 and links(inbox) or "empty"))

	add("")
	add("## Active projects")
	add("")
	local projects_root = M.vault .. "/projects"
	local any_project = false
	for _, path in ipairs(md_files(projects_root)) do
		local fm = frontmatter(read_lines(path))
		if fm.type == "project" and fm.status == "active" then
			local dir = vim.fs.dirname(path)
			-- A hub sitting directly in projects/ only counts its own tasks.
			local files = dir == projects_root and { path } or md_files(dir)
			local open = 0
			for _, file in ipairs(files) do
				open = open + count_open_tasks(read_lines(file))
			end
			add("- [[" .. stem(path) .. "]]: " .. plural(open, "open task"))
			any_project = true
		end
	end
	if not any_project then
		add("- None")
	end

	local cutoff = os.date("%Y-%m-%d", os.time() - 7 * 24 * 60 * 60)
	if cutoff < SYSTEM_START then
		cutoff = SYSTEM_START
	end
	local stragglers = {}
	for _, path in ipairs(dailies) do
		local day = stem(path)
		if day >= cutoff and day < today then
			local open = count_open_tasks(read_lines(path))
			if open > 0 then
				stragglers[#stragglers + 1] = "- [[" .. day .. "]]: " .. plural(open, "unchecked task")
			end
		end
	end
	if #stragglers > 0 then
		add("")
		add("## Stragglers")
		add("")
		add("Finish these, or move them to the backlog and mark the daily copy `[>]`.")
		add("")
		vim.list_extend(out, stragglers)
	end

	add("")
	add("## Recent days")
	add("")
	local recent = {}
	for i = #dailies, math.max(1, #dailies - 4), -1 do
		recent[#recent + 1] = dailies[i]
	end
	add(#recent > 0 and links(recent) or "None yet")

	local incidents = {}
	for _, path in ipairs(md_files(M.vault .. "/incidents")) do
		local fm = frontmatter(read_lines(path))
		if fm.type == "incident" then
			incidents[#incidents + 1] = { path = path, fm = fm, date = fm.date or stem(path) }
		end
	end
	table.sort(incidents, function(a, b)
		return a.date > b.date
	end)
	add("")
	add("## Incidents")
	add("")
	if #incidents == 0 then
		add("- None")
	end
	for i = 1, math.min(10, #incidents) do
		local incident = incidents[i]
		local details = { incident.fm.status or "status not set" }
		if incident.fm.ticket then
			details[#details + 1] = incident.fm.ticket
		end
		add("- [[" .. stem(incident.path) .. "]]: " .. table.concat(details, " · "))
	end

	local by_kind, kinds = {}, {}
	for _, path in ipairs(md_files(M.vault .. "/reference")) do
		local fm = frontmatter(read_lines(path))
		if fm.type == "reference" then
			local kind = fm.kind or "other"
			if not by_kind[kind] then
				by_kind[kind] = {}
				kinds[#kinds + 1] = kind
			end
			table.insert(by_kind[kind], path)
		end
	end
	table.sort(kinds)
	add("")
	add("## Reference")
	add("")
	if #kinds == 0 then
		add("- None")
	end
	for _, kind in ipairs(kinds) do
		add("- **" .. kind .. ":** " .. links(by_kind[kind]))
	end

	local updates = md_files(M.vault .. "/updates")
	if #updates > 0 then
		local latest = {}
		for i = #updates, math.max(1, #updates - 2), -1 do
			latest[#latest + 1] = updates[i]
		end
		add("")
		add("## Status updates")
		add("")
		add(links(latest))
	end

	return out
end

-- Rewrites the text between the home markers. Returns true if Home.md changed; the file
-- is only written when the content differs, so opening Home doesn't churn sync.
function M.refresh()
	local lines = read_lines(M.home)
	if not lines then
		return false
	end

	local block = {
		START,
		"<!-- Generated by Neovim whenever this note is opened (or <leader>nh). Edits between these markers are overwritten. -->",
		"",
	}
	vim.list_extend(block, M.build())
	block[#block + 1] = ""
	block[#block + 1] = FINISH

	local first, last
	for i, line in ipairs(lines) do
		if line == START then
			first = i
		elseif line == FINISH and first then
			last = i
			break
		end
	end

	local new = {}
	if first and last then
		vim.list_extend(new, lines, 1, first - 1)
		vim.list_extend(new, block)
		vim.list_extend(new, lines, last + 1, #lines)
	else
		local at = #lines
		for i, line in ipairs(lines) do
			if line:match("^# ") then
				at = i
				break
			end
		end
		vim.list_extend(new, lines, 1, at)
		new[#new + 1] = ""
		vim.list_extend(new, block)
		vim.list_extend(new, lines, at + 1, #lines)
	end

	local content = table.concat(new, "\n")
	if content == table.concat(lines, "\n") then
		return false
	end
	local f = assert(io.open(M.home, "w"))
	f:write(content, "\n")
	f:close()
	return true
end

function M.open()
	M.refresh()
	vim.cmd.edit(vim.fn.fnameescape(M.home))
	vim.cmd.checktime()
end

function M.setup()
	vim.api.nvim_create_autocmd("BufReadPre", {
		group = vim.api.nvim_create_augroup("NotesHome", { clear = true }),
		pattern = M.home,
		desc = "Regenerate the link section of the notes vault's Home.md",
		callback = function()
			local ok, err = pcall(M.refresh)
			if not ok then
				vim.notify("notes home: " .. tostring(err), vim.log.levels.WARN)
			end
		end,
	})
end

return M
