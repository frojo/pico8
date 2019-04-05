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

	-- knobs for boat feel (tm)
	water_drag = .01
	wind_force = water_drag * 1.5
	row_force = water_drag * 5

	-- timings for rowing
	stroke_catch_t = 12
	stroke_pull_t = 30
	-- this is an array where each element is info for animating the
	-- oars when rowing. ex. sprite index positional draw offset.
	-- each element is info for one possible rowing direction
	oar_anim = init_oar_anim()


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

	if (not boat.hidden) draw_rowboat(boat)


	if debug then
		print("cpu: "..tostr(stat(1)*100).."%")
		-- print("player state: "..tostr(players[1].state))
		-- print("player dir: "..tostr(players[1].dir))
		print("stroke_started: "..tostr(players[1].stroke_started))
		print("stroke_t: "..tostr(players[1].stroke_t))
		-- print("oar_anim test:"..oar_anim[1][1])
		if debug_err then
			print("err: "..debug_err)
		end
	end

end

function init_player(num)
	local player = {}
	player.num = num

	-- player states: 0 = pedestrian, 1 = swimming, 2 = rowing, 3 = sailing
	player.state = 0

	-- todo: delete when done developing rowing anim
	if (debug) player.state = 2
	
	if (num == 1) player.color = 4 -- brown
	if (num == 2) player.color = 5 -- dark grey

	player.x = 48
	player.y = 48
	player.h = 8
	player.w = 8
	player.dx = 0;
	player.dy = 0;
	player.facing_right = true

	-- north is 0, count clockwise
	player.dir = 0

	-- for rowing
	player.stroke_started = false
	player.stroke_t = 0

	player.alt_ctl = false

	return player
end


-- converts from world coords to map cell
function world_to_map_cell(x, y)
	return x / 8, y / 8
end

function dist(x1, y1, x2, y2)
	local dx = x2 - x1
	local dy = y2 - y1
	return sqrt(dx*dx + dy*dy)
end

function update_player_pedestrian(player)
		if player.dx > 0 then player.facing_right = true
		elseif player.dx < 0 then player.facing_right = false
		end

		-- check if in water
		local cellx, celly = world_to_map_cell(player.x, player.y)
		if fget(mget(cellx, celly), water_sf) then
			player.state = 1
		else
			player.state = 0
		end

		-- different indexing conventions are fun
		local pnum = player.num - 1

		-- handle input to move the player
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

		-- pressing c let's the player hop into the boat
		if btnp(4, pnum) then
			-- todo: delete after debug/dev
			if dist(player.x, player.y, boat.x, boat.y) < 8 then
				player.x = boat.x
				player.y = boat.y

				-- set player to rowing
				player.state = 2

				-- set direction to start off east
				player.dir = 2 
				boat.hidden = true
			end
		end
end

function update_player_rowing(player)
	rotate_player(player)



	if btn(5, player.num - 1) then
		if player.stroke_started == false then
			player.stroke_t = 0
			player.stroke_started = true
		else -- currently stroking
			if player.stroke_t < stroke_catch_t then
				-- todo: this assumes this will be called every tick
				-- that the player is stroking. is this always true?
			elseif player.stroke_t < stroke_catch_t + stroke_pull_t then
				-- apply a small continuous force
				forcex, forcey = row_force_on_player(player)
				player.dx += forcex * row_force
				player.dy += forcey * row_force
			else
			end
			player.stroke_t += 1
		end
	elseif player.stroke_started then
		player.stroke_started = false
		player.stroke_t = 0
	end

	-- todo: delete when done developing rowing anim move
	-- if (debug) return

	-- todo unify/refactor between this and the pedestrian stuff
	player.dx -= player.dx * water_drag
	player.dy -= player.dy * water_drag
	player.x += player.dx
	player.y += player.dy

end

function update_player(player)
	-- if swimming or standing
	if player.state == 0 or player.state == 1 then
		update_player_pedestrian(player)
	elseif player.state == 2 then
		update_player_rowing(player)
		-- todo: rowing motion
	end


	-- player.x += player.dx
	-- player.y += player.dy

	-- move_player(player)

end

function move_player_sailing(player)
	-- todo clean this shit up
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
			spr(1, player.x, player.y, 1, 1, not player.facing_right)
		else 
			spr(2, player.x, player.y, 1, 1, not player.facing_right)
		end

	-- walking animation
	-- todo: replace other animations logic with this way of doing it
	else
		local frames_per_sprite = 4
		local sprite_indices = {3, 4}
		local num_sprites = #sprite_indices
		local curr_sprite_idx = (t % (frames_per_sprite * num_sprites)) / frames_per_sprite
		spr(sprite_indices[flr(curr_sprite_idx)+1], player.x, player.y, 1, 1, not player.facing_right)
	end
	-- reset palette
	palt()

end

function draw_player_swimming(player)
	-- player swim sprite is drawn on lblue bg 
	palt(0, false)
	palt(12, true)
	spr(5, player.x, player.y, 1, 1, not player.facing_right)
	palt()
end

-- todo: for this and oar sprites and other things, probably a way to 
-- encapsulate it in a class or config type thing
-- returns the correct rowing sprite and whether it's x-flipped
function rowing_sprite(dir)
	if (dir == 0) then -- north, do nothing
		return 48, false
	elseif (dir == 1) then -- ne
		return 49, false
	elseif (dir == 2) then -- east
		return 50, false
	elseif (dir == 3) then -- se
		return 51, false
	elseif (dir == 4) then -- south
		return 52, false
	elseif (dir == 5) then -- sw
		return 51, true
	elseif (dir == 6) then -- west
		return 50, true
	elseif (dir == 7) then
		return 49, true
	end
		debug_err = "invalid dir for rowing sprite"
	return 0, false
end

-- returns oar catch sprite depending on the direction the rowboat is facing
-- and whether it's flipped
function oar_catch_sprite(dir)
	if (dir == 0) then -- north, do nothing
		return 48, false
	elseif (dir == 1) then -- ne
		return 49, false
	elseif (dir == 2) then -- east
		return 53, false
	elseif (dir == 3) then -- se
		return 51, false
	elseif (dir == 4) then -- south
		return 52, false
	elseif (dir == 5) then -- sw
		return 51, true
	elseif (dir == 6) then -- west
		return 50, true
	elseif (dir == 7) then
		return 49, true
	end
		debug_err = "invalid dir for rowing sprite"
	return 0, false
end

-- returns oar catch sprite depending on the direction the rowboat is facing
-- and whether it's flipped
function oar_catch_sprite(dir)
	if (dir == 0) then -- north, do nothing
		return 53, true
	elseif (dir == 1) then -- ne
		return 53, true
	elseif (dir == 2) then -- east
		return 53, true
	elseif (dir == 3) then -- se
		return 53, true
	elseif (dir == 4) then -- south
		return 53, true
	elseif (dir == 5) then -- sw
		return 53, true
	elseif (dir == 6) then -- west
		return 53, true
	elseif (dir == 7) then
		return 53, true
	end
		debug_err = "invalid dir for rowing sprite"
	return 0, false
end

-- info for animating oars when rowing
function init_oar_anim()
	local oar_anim = {}

	-- 	    loar(x, y, flippedx, flippedy)   roar(x, y, flippedx, flippedy)
	-- catch
	-- water
	-- release
	oar_anim.north = init_oar_dir_spr_params(
			  -4, -2, true, true, 3, -2, false, true,
			  -3, 4, false, false, 3, 4, false, false,
			  -4, 4, true, false, 3, 4, false, false)
	oar_anim.south = init_oar_dir_spr_params(
			  -4, 3, true, false, 3, 3, false, false,
			  -4, 4, true, false, 3, 4, false, false,
			  -5, -3, true, true, 4, -3, false, true)

	-- east and west have the same params for left and right oars
	-- because they only animate one oar when rowing
	oar_anim.east = init_oar_dir_spr_params(
			  0, 4, false, false, 0, 4, false, false,
			  0, 4, false, false, 0, 4, false, false,
			  -2, 4, true, false, -2, 4, true, false)
	oar_anim.west= init_oar_dir_spr_params(
			  0, 4, true, false, 0, 4, true, false,
			  1, 4, false, false, 1, 4, false, false,
			  2, 4, false, false, 2, 4, false, false)


	oar_anim.ne = init_oar_dir_spr_params(
			  1, 4, true, false, 100, 100, false, false,
			  0, 4, false, false, 100, 100, false, false,
			  -2, 4, false, false, 100, 100, true, false)
	oar_anim.nw = init_oar_dir_spr_params(
			  1, 4, true, false, 100, 100, false, false,
			  0, 4, false, false, 100, 100, false, false,
			  -2, 4, false, false, 100, 100, true, false)
	oar_anim.sw = init_oar_dir_spr_params(
			  1, 4, true, false, 100, 100, false, false,
			  0, 4, false, false, 100, 100, false, false,
			  -2, 4, false, false, 100, 100, true, false)
	oar_anim.se = init_oar_dir_spr_params(
			  1, 4, true, false, 100, 100, false, false,
			  0, 4, false, false, 100, 100, false, false,
			  -2, 4, false, false, 100, 100, true, false)


	return oar_anim
end

-- dir: {catch, water, release}
function init_oar_dir_spr_params( 
				   cloarx, cloary, clflippedx, clflippedy,
				   croarx, croary, crflippedx, crflippedy,
				   wloarx, wloary, wlflippedx, wlflippedy,
				   wroarx, wroary, wrflippedx, wrflippedy,
				   rloarx, rloary, rlflippedx, rlflippedy,
				   rroarx, rroary, rrflippedx, rrflippedy)
	local dir = {}

	dir.catch = init_oar_anim_phase(53,
	  		   cloarx, cloary, clflippedx, clflippedy,
	  		   croarx, croary, crflippedx, crflippedy)
	dir.water = init_oar_anim_phase(54,
	  		   wloarx, wloary, wlflippedx, wlflippedy,
	  		   wroarx, wroary, wrflippedx, wrflippedy)
	dir.release = init_oar_anim_phase(53,
				   rloarx, rloary, rlflippedx, rlflippedy,
				   rroarx, rroary, rrflippedx, rrflippedy)
	return dir
end

-- phase: {sprnum, loar, roar}
-- loar: {x, y, flippedx, flippedy}
function init_oar_anim_phase(sprnum, loarx, loary, lflippedx, lflippedy,
				     roarx, roary, rflippedx, rflippedy)
	local phase = {}
	phase.sprnum = sprnum

	-- sprite offsets and flippings
	local loar = {}
	loar.x = loarx
	loar.y = loary
	loar.flippedx = lflippedx
	loar.flippedy = lflippedy

	local roar = {}
	roar.x = roarx
	roar.y = roary
	roar.flippedx = rflippedx
	roar.flippedy = rflippedy
	
	phase.loar = loar
	phase.roar = roar
	return phase
end

function draw_oar_catch(player)
	local dir = player.dir
	if (dir == 0) then -- north
		local loarx = player.x - 4
		local loary = player.y - 2
		local roarx = player.x + 3
		local roary = player.y - 2
		local sprnum = 53
		local flippedx = false
		local flippedy = true
		spr(sprnum, loarx, loary, 1, 1, not flippedx, flippedy)
		spr(sprnum, roarx, roary, 1, 1, flipped, flippedy)
	elseif (dir == 2) then -- east
		local oarx = player.x + 1
		local oary = player.y + 4
		local sprnum = 53
		spr(sprnum, oarx, oary)
	elseif (dir == 4) then -- south
		local loarx = player.x - 4
		local loary = player.y + 3
		local roarx = player.x + 3
		local roary = player.y + 3
		local sprnum = 53
		local flippedx = false
		local flippedy = false
		spr(sprnum, loarx, loary, 1, 1, not flippedx, flippedy)
		spr(sprnum, roarx, roary, 1, 1, flipped, flippedy)
	end

end

function draw_oar_water(player)
	local dir = player.dir
	if (dir == 0) then -- north
		local loarx = player.x - 4
		local loary = player.y + 4
		local roarx = player.x + 3
		local roary = player.y + 4
		local sprnum = 54
		local flipped = false
		spr(sprnum, loarx, loary, 1, 1, not flipped)
		spr(sprnum, roarx, roary, 1, 1, flipped)
	elseif (dir == 2) then -- east
		local oarx = player.x 
		local oary = player.y + 4
		local sprnum = 54
		spr(sprnum, oarx, oary)
	elseif (dir == 4) then -- south
		local loarx = player.x - 3
		local loary = player.y + 4
		local roarx = player.x + 3
		local roary = player.y + 4
		local sprnum = 54
		local flipped = false
		spr(sprnum, loarx, loary, 1, 1, not flipped)
		spr(sprnum, roarx, roary, 1, 1, flipped)
	end

end

function draw_oar_release(player)
	local dir = player.dir
	if (dir == 0) then -- north
		local loarx = player.x - 4
		local loary = player.y + 4
		local roarx = player.x + 3
		local roary = player.y + 4
		local sprnum = 53
		local flipped = false
		spr(sprnum, loarx, loary, 1, 1, not flipped)
		spr(sprnum, roarx, roary, 1, 1, flipped)
	elseif (dir == 2) then -- east
		local oarx = player.x - 2
		local oary = player.y + 4
		local sprnum = 53
		local flipped = true
		spr(sprnum, oarx, oary, 1, 1, flipped)
	elseif (dir == 4) then -- south
		local loarx = player.x - 5
		local loary = player.y - 3
		local roarx = player.x + 4
		local roary = player.y - 3
		local sprnum = 53
		local flippedx = false
		local flippedy = true
		spr(sprnum, loarx, loary, 1, 1, not flippedx, flippedy)
		spr(sprnum, roarx, roary, 1, 1, flippedx, flippedy)
	end

end

function oar_anim_params(dir)
	if (dir == 0) then
		return oar_anim.north
	elseif (dir == 1) then
		return oar_anim.ne
	elseif (dir == 2) then
		return oar_anim.east
	elseif (dir == 3) then
		return oar_anim.se
	elseif (dir == 4) then
		return oar_anim.south
	elseif (dir == 5) then
		return oar_anim.sw
	elseif (dir == 6) then
		return oar_anim.west
	elseif (dir == 7) then 
		return oar_anim.nw
	end
		debug_err = "invalid dir for oar sprite params"
	return 0, false
end


function draw_player_rowing(player)
	-- player swim sprite is drawn on lblue bg 
	palt(0, false)
	palt(12, true)
	sprnum, flipped = rowing_sprite(player.dir)
	spr(sprnum, player.x, player.y, 1, 1, flipped)

	if player.stroke_started then

		local s = oar_anim_params(player.dir)
		-- will hold the oar animation parameters for 
		-- this phase of rowing
		local phase
		if player.stroke_t < stroke_catch_t then
			phase = s.catch
		elseif player.stroke_t < stroke_catch_t + stroke_pull_t then
			phase = s.water
		else
			phase = s.release
		end

		local l = phase.loar
		spr(phase.sprnum, 
			player.x + l.x, player.y + l.y, 1, 1,
			l.flippedx, l.flippedy)
			
		local r = phase.roar
		spr(phase.sprnum, 
			player.x + r.x, player.y + r.y, 1, 1,
			r.flippedx, r.flippedy)
	end


	palt()
end

function draw_player(player)
	if player.state == 0 then
		draw_player_pedestrian(player)
	elseif player.state == 1 then
		draw_player_swimming(player)
	elseif player.state == 2 then
		draw_player_rowing(player)
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
	-- for when player is in boat so we don't want to draw it
	boat.hidden = false
	return boat
end

function draw_rowboat(boat)
	palt(0, false)
	palt(12, true)
	spr(34, boat.x, boat.y)
	palt()
end


__gfx__
00000000cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc00000000000000000000000000000000000000000000000000000000
00000000cc0000cccccccccccc0000cccc0000cccccccccccccccccccccccccccccccccc00000000000000000000000000000000000000000000000000000000
00700700cc5444cccc0000cccc5444cccc5444cccccccccccccccccccccccccccccccccc00000000000000000000000000000000000000000000000000000000
00077000cc4040cccc5444cccc4040cccc4040cccc0000cccccccccccccccccccccccccc00000000000000000000000000000000000000000000000000000000
00077000cc4444cccc4040cccc4444cccc4444cccc5444cccccccccccccccccccccccccc00000000000000000000000000000000000000000000000000000000
00700700cc7777cccc4444cccc7777cccc7777cccc4040cccccccccccccccccccccccccc00000000000000000000000000000000000000000000000000000000
00000000cc2222cccc7777cccc22220cc02222cccc4444cccccccccccccccccccccccccc00000000000000000000000000000000000000000000000000000000
00000000cc0cc0cccc0cc0cccc0cccccccccc0cccccccccccccccccccccccccccccccccc00000000000000000000000000000000000000000000000000000000
1111111155555555fafafafa0000000000000000000000000000000000000000000000000000000000000000cccccccccccccccc000000000000000000000000
1111111155555555afafafaf0000000000000000000000000000000000000000000000000000000000000000cccccccccccccccc000000000000000000000000
1111111155555555fafafafa0000000000000000000000000000000000000000000000000000000000000000cccccccccccccccc000000000000000000000000
1111111155555555afafafaf0000000000000000000000000000000000000000000000000000000000000000cccccccccccccccc000000000000000000000000
1111111155555555fafafafa0000000000000000000000000000000000000000000000000000000000000000cccccccccccccccc000000000000000000000000
1111111155555555afafafaf0000000000000000000000000000000000000000000000000000000000000000cccccccccccccccc000000000000000000000000
1111111155555555fafafafa0000000000000000000000000000000000000000000000000000000000000000cccccccccccccccc000000000000000000000000
1111111155555555afafafaf0000000000000000000000000000000000000000000000000000000000000000cccccccccccccccc000000000000000000000000
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc4ccccccc4cccccccccccc000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccc5cccccccccccccccccccccccccccccccc4ccccccc4cccccccccccc000000000000000000000000000000000000000000000000
ccc55cccccc555cc5555555cc505cccccccccccccccccccccccccccccc747cccccc4cccccccccccc000000000000000000000000000000000000000000000000
cc5005cccc5005cc5000000555005ccccc5555cccccccccccccccccccc777ccccc747ccccccccccc000000000000000000000000000000000000000000000000
cc5005ccc50055cc55555555c55005cccc5005cccccccccccccccccccccccccccc777ccccccccccc000000000000000000000000000000000000000000000000
cc5555cc55555ccc5555555ccc5555cccc5005cccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000
cc5555ccc555ccccccccccccccc555cccc5555cccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000
cccccccccc5cccccccccccccccccccccccc55ccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000
cc000ccccc000ccccc0000ccccccccccccccccccc44cccccccc4ccccccc4ccccccc4cccc44cccccccccccccc0000000000000000000000000000000000000000
cc444ccccc445ccccc4445cccc000ccccc000ccccc44ccccccc4ccccccc4ccccccc4ccccc444cccccccccccc0000000000000000000000000000000000000000
cc040ccccc4445cccc0404cccc455ccccc000cccccc444ccccc4cccccc747ccccc747ccccc444ccccccccccc0000000000000000000000000000000000000000
cc444ccccc7775cccc4444ccc5444cccc54445cccccc444cccc4cccccc747ccccc777ccccc44cccccccccccc0000000000000000000000000000000000000000
c57775ccc52225cc5577775c55777cccc57775cccccc444ccc747ccccc777ccccccccccccccccccccccccccc0000000000000000000000000000000000000000
c52225cc55555ccc50222205c52225ccc52225ccccccc4cccc777ccccccccccccccccccccccccccccccccccc0000000000000000000000000000000000000000
c55555ccc555cccc55555555cc5555ccc55555cccccccccccccccccccccccccccccccccccccccccccccccccc0000000000000000000000000000000000000000
c55555cccc5ccccc5555555cccc555cccc555ccccccccccccccccccccccccccccccccccccccccccccccccccc0000000000000000000000000000000000000000
__gff__
0000000000000000000108000000000010010800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1111111111111111111111111111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1110101010101010101010101010101100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1110101010101010101010101010101100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1110101010101010101010101010101100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1110101010101010101010101010101100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1110101010101010101010101010111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1110101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1110101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1110101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1110101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1110101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1110101010101010101010101010101100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1110101010101010101010101010101100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1110101010101010101010101010101100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1110101010101010101010101010101100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
011004012f05021300136301570023050230001363001000136302d5001b750147002e0502e00022750290002f0502e000126302b500230502a500126302a500116302a50017750167001b7501b7002275022700
001000001965000000000000000000000000001865000000186501860000000000000000000000000001460016650066000000000000156000000016650000001765000000000000000000000000000000000000
