-- Fireworks: rockets launch from the bottom of the buffer, climb to a
-- random height, then burst into radiating sparks that fade out, consuming
-- the text they pass through.

local M = {
	name = "fireworks",
	fps = 40,
	max_frames = 320,
	max_rockets = 5,
	spawn_chance = 0.15,
}

local function cell_at(grid, x, y)
	local row = grid[x]
	if row == nil then
		return nil
	end
	return row[y]
end

local state

M.init = function(grid)
	state = {
		height = #grid,
		rockets = {},
		frame = 0,
	}
end

local function spawn_rocket(grid)
	local launch_row = state.height
	while launch_row > 1 and #grid[launch_row] == 0 do
		launch_row = launch_row - 1
	end
	if #grid[launch_row] == 0 then
		return
	end

	local apex_row = math.max(1, math.floor(launch_row * (0.2 + math.random() * 0.4)))
	table.insert(state.rockets, {
		x = launch_row,
		y = math.random(1, #grid[launch_row]),
		apex_row = apex_row,
		phase = "rising",
		particles = {},
	})
end

local function explode(rocket)
	rocket.phase = "exploded"
	local n = math.random(10, 14)
	for i = 1, n do
		local angle = (i / n) * 2 * math.pi + (math.random() - 0.5) * 0.3
		local speed = 0.6 + math.random() * 0.8
		table.insert(rocket.particles, {
			x = rocket.x,
			y = rocket.y,
			dx = math.sin(angle) * speed * 0.6, -- rows: compress vertically
			dy = math.cos(angle) * speed,
			life = math.random(8, 14),
			max_life = 14,
		})
	end
end

local function spark_char(life, max_life)
	local ratio = life / max_life
	if ratio > 0.6 then
		return "*"
	elseif ratio > 0.3 then
		return "+"
	else
		return "."
	end
end

M.update = function(grid)
	state.frame = state.frame + 1

	if state.frame < M.max_frames and #state.rockets < M.max_rockets and math.random() < M.spawn_chance then
		spawn_rocket(grid)
	end

	local any_active = false

	for ri = #state.rockets, 1, -1 do
		local rocket = state.rockets[ri]

		if rocket.phase == "rising" then
			any_active = true
			local old = cell_at(grid, rocket.x, rocket.y)
			if old ~= nil then
				old.char = " "
			end
			rocket.x = rocket.x - 1
			if rocket.x <= rocket.apex_row then
				explode(rocket)
			else
				local cell = cell_at(grid, rocket.x, rocket.y)
				if cell ~= nil then
					cell.char = "|"
					cell.hl_group = "Special"
				end
			end
		end

		if rocket.phase == "exploded" then
			for pi = #rocket.particles, 1, -1 do
				local p = rocket.particles[pi]
				local old = cell_at(grid, math.floor(p.x + 0.5), math.floor(p.y + 0.5))
				if old ~= nil then
					old.char = " "
				end

				p.life = p.life - 1
				p.x = p.x + p.dx
				p.y = p.y + p.dy

				if p.life <= 0 then
					table.remove(rocket.particles, pi)
				else
					any_active = true
					local cell = cell_at(grid, math.floor(p.x + 0.5), math.floor(p.y + 0.5))
					if cell ~= nil then
						cell.char = spark_char(p.life, p.max_life)
						cell.hl_group = "Special"
					end
				end
			end

			if #rocket.particles == 0 then
				table.remove(state.rockets, ri)
			end
		end
	end

	return any_active or state.frame < M.max_frames
end

return M
