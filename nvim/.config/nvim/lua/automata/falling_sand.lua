-- Falling Sand: turns every character in the buffer into a physical grain of
-- sand with gravity and diagonal slip-slopes, collapsing code structures into
-- syntax-highlighted sand dunes along the bottom of the window.

local M = {
	name = "falling_sand",
	fps = 50,
	steps_per_frame = 2,
	max_frames = 300,
}

local state

local function is_empty(cell)
	return cell ~= nil and cell.char == " "
end

local function swap_cells(a, b)
	a.char, b.char = b.char, a.char
	a.hl_group, b.hl_group = b.hl_group, a.hl_group
end

M.init = function(grid)
	state = {
		height = #grid,
		frame = 0,
	}
end

local function step(grid)
	local moved = false
	for r = state.height - 1, 1, -1 do
		local row = grid[r]
		local below_row = grid[r + 1]
		if row ~= nil and below_row ~= nil then
			local width = #row
			-- Alternate horizontal scan sweep direction to avoid directional bias
			local start_c, end_c, dir_c
			if math.random() < 0.5 then
				start_c, end_c, dir_c = 1, width, 1
			else
				start_c, end_c, dir_c = width, 1, -1
			end

			for c = start_c, end_c, dir_c do
				local cell = row[c]
				if cell ~= nil and cell.char ~= " " then
					local down = below_row[c]
					if is_empty(down) then
						swap_cells(cell, down)
						moved = true
					else
						local dl = below_row[c - 1]
						local dr = below_row[c + 1]
						local first, second = dl, dr
						if math.random() < 0.5 then
							first, second = dr, dl
						end
						if is_empty(first) then
							swap_cells(cell, first)
							moved = true
						elseif is_empty(second) then
							swap_cells(cell, second)
							moved = true
						end
					end
				end
			end
		end
	end
	return moved
end

M.update = function(grid)
	state.frame = state.frame + 1
	local any_moved = false
	for _ = 1, M.steps_per_frame do
		if step(grid) then
			any_moved = true
		end
	end
	return any_moved and state.frame < M.max_frames
end

return M
