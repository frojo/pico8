pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

-- sprite flag notes
-- blue means water 
-- green means land
-- red means die-on-touch

function _init()
	debug = true

	-- collisions
	walls_spr_flag = 0
	walls_map_offset = 16

-- sprite flag notes
-- blue means water 
-- green means land
-- red means die-on-touch
	-- sprite flags
	water_sf = 4 -- blue
	land_sf = 3 -- green
	rocks_sf = 0 -- red

	players = {}
	add(players, init_player(1))

	-- init row boat
	boat = init_rowboat(64, 48)

	walk_speed = .8

	-- knobs for Boat Feel (TM)
	water_drag = .01
	wind_force = water_drag * 1.5
	row_force = water_drag * 50

	-- precalc this for use later
	k_invsqrt2 = 1 / sqrt(2)

	-- which screen is it
	screen = 0

	-- is it windy?
	windy = false

	-- number of frames
	t = 0

end

function _update()
	for player in all(players) do
		update_player(player)
	end

	t += 1
end

function _draw()
	cls()

	-- draw screen
	map(screen*16, screen*16, 0, 0, 16, 16)

	-- draw players
	for player in all(players) do
		draw_player(player)
	end

	draw_rowboat(boat)


	if debug then
		print("               cpu: "..tostr(stat(1)*100).."%")
		-- print("               sprite idx: "..tostr(curr_sprite_idx))
		print("               player state: "..tostr(players[1].state))
		print("               in water: "..tostr(in_water))
		-- print("               cellx: "..tostr(cellx))
		-- print("               celly: "..tostr(celly))
		-- print("               player x: "..tostr(players[1].x))
		-- print("               player y: "..tostr(players[1].y))
		-- print("               tried move?: "..tostr(tried_to_move))
	end

end

function init_player(num)
	local player = {}
	player.num = num

	-- 0 = pedestrian, 1 = swimming, 2 = rowing, 3 = sailing
	player.state = 0
	
	if (num == 1) player.color = 4 -- brown
	if (num == 2) player.color = 5 -- dark grey

	player.x = 24
	player.y = 48
	player.h = 8
	player.w = 8
	player.dx = 0;
	player.dy = 0;

	-- north is 0, count clockwise
	player.dir = 0

	player.alt_ctl = false

	return player
end


-- converts from world coords to map cell
function world_to_map_cell(x, y)
	return x / 8, y / 8
end

function update_player(player)
	-- check if swimming or standing
	-- todo
	if player.state == 0 or player.state == 1 then
		local cellx, celly = world_to_map_cell(player.x, player.y)
		-- check if in water
		if fget(mget(cellx, celly), water_sf) then
			in_water = true
			player.state = 1
		else
			in_water = false
			player.state = 0
		end
	end
	

	rotate_player(player)
	move_player(player)
end

function move_player(player)
	-- different indexing conventions are fun
	local pnum = player.num - 1

	if player.state == 0 or player.state == 1 then
		-- TODO lol
		player.dx = 0
		player.dy = 0
		if btn(0, pnum) then 
			player.dx = -1
		end
		if btn(1, pnum) then
			player.dx = 1
		end
		if btn(2, pnum) then 
			player.dy = -1
		end
		if btn(3, pnum) then
			player.dy = 1
		end
		player.x += player.dx * walk_speed
		player.y += player.dy * walk_speed
		return
	end

	-- TODO clean this shit up
	-- add wind force
	local forcex, forcey
	if (windy) then
		forcex, forcey = wind_force_on_player(player)
		forcex *= wind_force
		forcey *= wind_force
	else
		forcex, forcey = row_force_on_player(player)
		forcex *= row_force
		forcey *= row_force
		
	end
	player.dx += forcex - player.dx * water_drag
	player.dy += forcey - player.dy * water_drag

	-- handle collisions in x direction
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

	-- handle collisions in y direction
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

function row_force_on_player(player)
	local dx = 0;
	local dy = 0;
	if (btnp(5)) then
		if (player.dir == 0) then -- north, do nothing
			dy = -1
		elseif (player.dir == 1) then -- ne
			dx = k_invsqrt2
			dy = -k_invsqrt2
		elseif (player.dir == 2) then -- east
			dx = 1
		elseif (player.dir == 3) then -- se
			dx = k_invsqrt2
			dy = k_invsqrt2
		elseif (player.dir == 4) then -- south
			dy = 1
		elseif (player.dir == 5) then -- sw
			dx = -k_invsqrt2
			dy = k_invsqrt2
		elseif (player.dir == 6) then -- west
			dx = -1
		else -- (player.dir == 7) -- nw
			dx = -k_invsqrt2
			dy = -k_invsqrt2
		end
	end
	return dx, dy
end

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
	-- correct for pico8 btn interface (which is 0-based)
	local pnum = player.num - 1
	-- 0 = left, 1 = right, 2 = up, 3 = down
	
	if (player.alt_ctl) then
		if (btn(0, pnum) and btn(2, pnum)) then  player.dir = 7
		elseif (btn(2, pnum) and btn(1, pnum)) then player.dir = 1
		elseif (btn(1, pnum) and btn(3, pnum)) then player.dir = 3
		elseif (btn(3, pnum) and btn(0, pnum)) then player.dir = 5
		elseif (btn(0, pnum)) then player.dir = 6
		elseif (btn(1, pnum)) then player.dir = 2
		elseif (btn(2, pnum)) then player.dir = 0
		elseif (btn(3, pnum)) then player.dir = 4
		end
	else
		if (btnp(0, pnum)) player.dir = (player.dir - 1) % 8
		if (btnp(1, pnum)) player.dir = (player.dir + 1) % 8
	end
end

function draw_player_pedestrian(player)
	-- player sprite is drawn on lblue bg 
	palt(0, false)
	palt(12, true)
	-- idle animation
	if player.dx == 0 and player.dy == 0 then
		if (t % 90) < 45 then
			spr(32, player.x, player.y)
		else 
			spr(33, player.x, player.y)
		end

	-- walking animation
	-- todo: replace other animations logic with this way of doing it
	else
		
		local flipx = player.dx < 0
		local frames_per_sprite = 4
		local sprite_indices = {34, 35}
		local num_sprites = #sprite_indices
		local curr_sprite_idx = (t % (frames_per_sprite * num_sprites)) / frames_per_sprite
		spr(sprite_indices[flr(curr_sprite_idx)+1], player.x, player.y, 1, 1, flipx)
	end
	-- reset palette
	palt()

end

function draw_player_swimming(player)
	-- player sprite is drawn on lblue bg 
	palt(0, false)
	palt(12, true)
	-- idle animation
	if player.dx == 0 and player.dy == 0 then
		if (t % 60) < 20 then
			spr(36, player.x, player.y)
		else 
			spr(37, player.x, player.y)
		end

	-- walking animation
	-- todo: replace other animations logic with this way of doing it
	else
		
		local flipx = player.dx < 0
		local frames_per_sprite = 4
		local sprite_indices = {34, 35}
		local num_sprites = #sprite_indices
		local curr_sprite_idx = (t % (frames_per_sprite * num_sprites)) / frames_per_sprite
		spr(sprite_indices[flr(curr_sprite_idx)+1], player.x, player.y, 1, 1, flipx)
	end
	-- reset palette
	palt()
end


function draw_player(player)
	if player.state == 0 then
		draw_player_pedestrian(player)
	elseif player.state == 1 then
		draw_player_swimming(player)
	-- player is sailing
	elseif player.state == 3 then
		-- the boat sprites just happen to be in the beginning of
		-- the sprite sheet
		local sprite = player.dir + 1
		if (player.num == 2) pal(4, 5)
		spr(sprite, player.x, player.y)
		if (player.num == 2) pal()
	end
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

function init_rowboat(x, y)
	boat = {}
	boat.x = x
	boat.y = y
	return boat
end

function draw_rowboat(boat)
	palt(0, false)
	palt(12, true)
	spr(48, boat.x, boat.y)
	palt()
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
1111111155555555fafafafa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111155555555afafafaf00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111155555555fafafafa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111155555555afafafaf00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111155555555fafafafa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111155555555afafafaf00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111155555555fafafafa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111155555555afafafaf00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccc1111111111111111cccccccccccccccc0000000000000000000000000000000000000000000000000000000000000000
cc0000cccccccccccc0000cccc0000cc1111111111111111cccccccccccccccc0000000000000000000000000000000000000000000000000000000000000000
cc5444cccc0000cccc5444cccc5444cc1100001111111111cccccccccccccccc0000000000000000000000000000000000000000000000000000000000000000
cc4040cccc5444cccc4040cccc4040cc1154441111000011cccccccccccccccc0000000000000000000000000000000000000000000000000000000000000000
cc4444cccc4040cccc4444cccc4444cc1140401111544411cccccccccccccccc0000000000000000000000000000000000000000000000000000000000000000
cc7777cccc4444cccc7777cccc7777cc1144441111404011cccccccccccccccc0000000000000000000000000000000000000000000000000000000000000000
cc2222cccc7777cccc22220cc02222cc1177771111444411cccccccccccccccc0000000000000000000000000000000000000000000000000000000000000000
cc0cc0cccc0cc0cccc0cccccccccc0cc1111111111111111cccccccccccccccc0000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccc0000cccccccccccccccccccccccccccccccccccccccccccccccccc0000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccc4445cccccccccccccccccccccccccccccccccccccccccccccccccc0000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccc0404cccccccccccccccccccccccccccccccccccccccccccccccccc0000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccc4444cccccccccccccccccccccccccccccccccccccccccccccccccc0000000000000000000000000000000000000000
5555555ccccccccccccccccccccccccc5577775ccccccccccccccccccccccccccccccccccccccccccccccccc0000000000000000000000000000000000000000
50000005cccccccccccccccccccccccc50222205cccccccccccccccccccccccccccccccccccccccccccccccc0000000000000000000000000000000000000000
55555555cccccccccccccccccccccccc55555555cccccccccccccccccccccccccccccccccccccccccccccccc0000000000000000000000000000000000000000
5555555ccccccccccccccccccccccccc5555555ccccccccccccccccccccccccccccccccccccccccccccccccc0000000000000000000000000000000000000000
__gff__
0000000000000004080108000000000010010800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1111111111111111111111111111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1110101010101010101010101010101100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1110101010101010101010101010101100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1110101010101010101010101010101100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1112121212121210101010101010101100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1112121212121210101010101010111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1112121212121210101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1112121212121210101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1112121212121210101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1112121212121210101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1112121212121210101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1112121212121210101010101010101100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1110101010101010101010101010101100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1110101010101010101010101010101100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1110101010101010101010101010101100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
011004012f05021300136301570023050230001363001000136302d5001b750147002e0502e00022750290002f0502e000126302b500230502a500126302a500116302a50017750167001b7501b7002275022700
001000001965000000000000000000000000001865000000186501860000000000000000000000000001460016650066000000000000156000000016650000001765000000000000000000000000000000000000
