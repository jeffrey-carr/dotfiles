-- Shared "is this buffer large?" predicate, used to gate expensive
-- per-keystroke/per-cursor-move plugins (biscuits, dropbar, smear-cursor,
-- blink.cmp buffer completion, tiny-inline-diagnostic multilines) on files
-- like a multi-thousand-line Go file, well below snacks.nvim's own bigfile
-- threshold (1.5MB), which is reserved for truly huge/minified files.
local M = {}

M.max_lines = 2000
M.max_bytes = 150 * 1024

function M.compute(bufnr)
	bufnr = bufnr or 0
	if vim.bo[bufnr].filetype == "bigfile" then
		return true
	end
	if vim.api.nvim_buf_line_count(bufnr) > M.max_lines then
		return true
	end
	local name = vim.api.nvim_buf_get_name(bufnr)
	if name ~= "" then
		local size = vim.fn.getfsize(name)
		if size > 0 and size > M.max_bytes then
			return true
		end
	end
	return false
end

-- Cached per-buffer so repeated calls per keystroke/cursor-move are cheap.
function M.is_large(bufnr)
	bufnr = bufnr or 0
	local cached = vim.b[bufnr].bigbuf
	if cached ~= nil then
		return cached
	end
	local result = M.compute(bufnr)
	vim.b[bufnr].bigbuf = result
	return result
end

vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "BufFilePost" }, {
	group = vim.api.nvim_create_augroup("BigBufDetect", { clear = true }),
	callback = function(args)
		vim.b[args.buf].bigbuf = nil
		M.is_large(args.buf)
	end,
})

return M
