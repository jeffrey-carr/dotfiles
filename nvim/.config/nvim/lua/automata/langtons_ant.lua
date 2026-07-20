-- Langton's Ant: a single "ant" walks the buffer, flipping cells on/off
-- following the classic rule (turn right on empty, left on filled, flip,
-- step forward). Starts from your actual code and slowly dissolves into
-- chaos before (usually) resolving into a diagonal "highway".

local M = {
	name = "langtons_ant",
	fps = 60,
	steps_per_frame = 25,
	max_frames = 500,
}

local DIRS = {
	{ -1, 0 }, -- north
	{ 0, 1 }, -- east
	{ 1, 0 }, -- south
	{ 0, -1 }, -- west
}

local state

M.init = function(grid)
	local height = #grid
	local width = 1
	for i = 1, height do
		width = math.max(width, #grid[i])
	end

	local visited = {}
	local orig = {}
	for i = 1, height do
		visited[i] = {}
		orig[i] = {}
		for j = 1, width do
			local cell = grid[i][j]
			visited[i][j] = cell ~= nil and cell.char ~= " "
			orig[i][j] = cell
		end
	end

	state = {
		height = height,
		width = width,
		visited = visited,
		orig = orig,
		x = math.ceil(height / 2),
		y = math.ceil(width / 2),
		dir = 1,
		frame = 0,
	}
end

M.update = function(grid)
	state.frame = state.frame + 1

	for _ = 1, M.steps_per_frame do
		local filled = state.visited[state.x][state.y]
		if filled then
			state.dir = (state.dir - 2) % 4 + 1 -- turn left
		else
			state.dir = state.dir % 4 + 1 -- turn right
		end
		state.visited[state.x][state.y] = not filled

		local d = DIRS[state.dir]
		state.x = ((state.x - 1 + d[1]) % state.height) + 1
		state.y = ((state.y - 1 + d[2]) % state.width) + 1
	end

	for i = 1, state.height do
		for j = 1, state.width do
			local cell = grid[i] and grid[i][j]
			if cell ~= nil then
				if state.visited[i][j] then
					local orig_cell = state.orig[i][j]
					if orig_cell ~= nil and orig_cell.char ~= " " then
						cell.char = orig_cell.char
						cell.hl_group = orig_cell.hl_group
					else
						cell.char = "#"
					end
				else
					cell.char = " "
				end
			end
		end
	end

	return state.frame < M.max_frames
end

return M
