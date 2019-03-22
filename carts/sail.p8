pico-8 cartridge // http://www.pico-8.com
version 16
__lua__


function _init()
	-- bookkeeping vars for racing
	race_region0_spr_flag = 1
	race_region1_spr_flag = 2
	race_region2_spr_flag = 3
	race_region_map_offset = 16
	points_to_win = 3
	gameover = false

	-- collisions
	walls_spr_flag = 0
	walls_map_offset = 16

	players = {}
	add(players, init_player(1))
	add(players, init_player(2))

	wind_dir = "south"

	-- knobs for Boat Feel (TM)
	water_drag = .075
	wind_force = water_drag * 1.5

	-- wind lines
	wind_lines = {}
	init_wind_lines()

end

function _update()
	for player in all(players) do
		update_player(player)
	end
	update_wind_lines()
end

function _draw()
	cls()
	draw_water()
	draw_marks()
	for player in all(players) do
		draw_player(player)
		draw_points(player)
	end

	draw_wind_lines()

	if (gameover) then
		print("player "..tostr(winner.num).." wins!", 32, 64, winner.color)
		print("(ctrl-r to restart)", 24, 72, winner.color)

	end



	print("       cpu usage: "..tostr(stat(1)*100).."%")

end

function init_player(num)
	local player = {}
	player.num = num
	
	if (num == 1) player.color = 4 -- brown
	if (num == 2) player.color = 5 -- dark grey

	player.x = 10
	player.y = 96 + 10 * player.num
	player.h = 8
	player.w = 8
	player.dx = 0;
	player.dy = 0;

	player.hit_race_region0 = false;
	player.hit_race_region1 = false;
	player.points = 0

	-- north is 0, count clockwise
	player.dir = 0

	return player
end

function update_player(player)
	rotate_player(player)
	move_player(player)
	if (not gameover) mark_race_progress(player)
end

function move_player(player)
	-- add wind force and water drag
	local wind_x, wind_y = wind_force_on_player(player)
	player.dx += wind_x * wind_force - player.dx * water_drag
	player.dy += wind_y * wind_force - player.dy * water_drag

	-- implement players colliding into each other here

	if in_wall_region(player.x + player.dx, player.y, player.w, player.h) or 
		offscreen(player.x + player.dx, player.y, player.w, player.h) then
		player.dx = -player.dx
	else
		local overlapping_player = nil
		for other_player in all(players) do
			if overlaps_player(player.x + player.dx, player.y, player.w, player.h, other_player) then
				overlapping_player = other_player
				break
			end
		end

		if overlapping_player then
			tmpdx = player.dx
			player.dx = overlapping_player.dx
			overlapping_player.dx = tmpdx

		else 
			player.x += player.dx
		end
	end

	if in_wall_region(player.x, player.y + player.dy, player.w, player.h) or
		offscreen(player.x, player.y + player.dy, player.w, player.h) then
		player.dy = -player.dy
	else
		local overlapping_player = nil
		for other_player in all(players) do
			if overlaps_player(player.x, player.y + player.dy, player.w, player.h, other_player) then
				overlapping_player = other_player
				break
			end
		end

		if overlapping_player then
			tmpdy = player.dy
			player.dy = overlapping_player.dy
			overlapping_player.dy = tmpdy

		else 
			player.y += player.dy
		end
	end
end
-- todo: use metatable to implement vectors and use those for velocity stuff
-- so that we don't have to duplicate code everywhere?

function wind_force_on_player(player)
	-- move player from the wind
	-- hardcode to just south at first
	dx = 0;
	dy = 0;
	if (player.dir == 0) then -- north, do nothing
	elseif (player.dir == 1) then -- ne
		dx = 1
		dy = -1
	elseif (player.dir == 2) then -- east
		dx = 2
	elseif (player.dir == 3) then -- se
		dx = 1
		dy = 1
	elseif (player.dir == 4) then -- south
		dy = 1
	elseif (player.dir == 5) then -- sw
		dx = -1
		dy = 1
	elseif (player.dir == 6) then -- west
		dx = -2
	else -- (player.dir == 7) -- nw
		dx = -1
		dy = -1
	end
	return dx, dy
end

function rotate_player(player)
	if (player.num == 1) then
		if (btnp(0)) player.dir = (player.dir - 1) % 8
		if (btnp(1)) player.dir = (player.dir + 1) % 8
	end
	if (player.num == 2) then
		if (btnp(4)) player.dir = (player.dir - 1) % 8
		if (btnp(5)) player.dir = (player.dir + 1) % 8
	end
end

function draw_player(player)
	-- the sprites just happen to be in beginning of sprite sheet
	local sprite = player.dir + 1
	if (player.num == 2) pal(4, 5)
	spr(sprite, player.x, player.y)
	if (player.num == 2) pal()
end

function draw_marks()
	-- also draws the hidden race regions
	map(16, 0, 0, 0, 16, 16, 1)
end

function draw_water()
	map(0, 0, 0, 0, 16, 16)
end

function draw_points(player) 
	print(tostr(player.points), 8 * player.num, 4, player.color)
end

function mark_race_progress(player) 
	-- check all the race things here and increment score if applicable

	if in_race_region(player, race_region2_spr_flag) then
	walls_map_offset = 16
		if (player.hit_race_region0 and player.hit_race_region1) then
			player.points += 1
			player.hit_race_region0 = false
			player.hit_race_region1 = false
		end
	elseif in_race_region(player, race_region1_spr_flag) then
		if (player.hit_race_region0) player.hit_race_region1 = true
	elseif in_race_region(player, race_region0_spr_flag) then
		player.hit_race_region0 = true
	end

	if (player.points >= points_to_win) then
		winner = player
		gameover = true
	end
	

end

-- check if player is in the appropriate race region
function in_race_region(player, race_region_spr_flag)
	cellx = player.x / 8 + race_region_map_offset
	celly = player.y / 8
	return fget(mget(cellx, celly), race_region_spr_flag)
end

-- check if cell x,y (in map space) is a wall
function in_wall(x, y)
	return fget(mget(x, y), walls_spr_flag)
end

-- check if pixel at x, y is offscreen
function offscreen(x, y, w, h)
	return 
		x + w < 0 or x < 0 or 
		x > 128 or x + w > 128 or
		y + h < 0 or y < 0 or 
		y > 128 or y + h > 128
end

-- check if point at (x, y) is in player
function in_player(x, y, player)
	return x > player.x and x < player.x + player.w and
		y > player.y and y < player.y + player.h
end

-- check if rect given by args overlaps with a player
-- only works for rects that are <= player size
function overlaps_player(x, y, w, h, player)
	return
		in_player(x, y, player) or
		in_player(x + w, y, player) or
		in_player(x, y + h, player) or
		in_player(x + w, y + h, player)

end

-- check if rect given by args overlaps with a wall
function in_wall_region(x, y, w, h)

	local cellx_min = x / 8 + walls_map_offset
	local cellx_max = (x + w) / 8 + walls_map_offset
	local celly_min = y / 8 
	local celly_max = (y + h) / 8 

	return
		in_wall(cellx_min, celly_min) or
		in_wall(cellx_max, celly_min) or
		in_wall(cellx_min, celly_max) or
		in_wall(cellx_max, celly_max)
end

function init_wind_lines()
	local line1 = {}
	line1.x1 = 42
	line1.y1 = 42
	line1.x2 = 69
	line1.y2 = 69
	add(wind_lines, line1)
end

function update_wind_lines()
	--hardcode to southward wind


end

function draw_wind_lines()
	for wind_line in all(wind_lines) do
		line(wind_line.x1, wind_line.y1,
			wind_line.x2, wind_line.y2, 7)
	end

end

__gfx__
00000000000400000500000000000000000400000047444000004000000570000000000000000000000000000000000000000000000000000000000000000000
00000000004440000754444044444400007777750077444000044400000577000444400000000000000000000000000000000000000000000000000000000000
00700700044444000775444044444440044777500777444000444470004577740444440000000000000000000000000000000000000000000000000000000000
00077000044555550777544044445444444475407777444004444774044577770445444000000000000000000000000000000000000000000000000000000000
00077000044477774774444077775440044454405555544004457770444544440457444400000000000000000000000000000000000000000000000000000000
00700700044477700744440047775400004444400044444004445770044444440577744000000000000000000000000000000000000000000000000000000000
00000000044477000044400000775000000444400004440004444570004444445777770000000000000000000000000000000000000000000000000000000000
00000000044474000004000000075000000000000000400000000050000000000000400000000000000000000000000000000000000000000000000000000000
cccccccc008888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc088888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc088888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc008888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbaaaaaaaa8888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbaaaaaaaa8888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbaaaaaaaa8888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbaaaaaaaa8888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbaaaaaaaa8888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbaaaaaaaa8888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbaaaaaaaa8888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbaaaaaaaa8888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000004080108000000000000010000000000000000000000000000020408000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1010101010101010101010101010101000000000000000000000002121212121000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101000000000000000000000002121212121000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101000000000000000000000001121212121000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101022222211000000000000001120202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101022222222000000000000002020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101022222222000000000000002020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101022222222000000000000002020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
011004012f05021300136301570023050230001363001000136302d5001b750147002e0502e00022750290002f0502e000126302b500230502a500126302a500116302a50017750167001b7501b7002275022700
001000001965000000000000000000000000001865000000186501860000000000000000000000000001460016650066000000000000156000000016650000001765000000000000000000000000000000000000
