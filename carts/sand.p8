pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

-- inspired by the gdc tech talk for noita

debug = true
debug_check = 0

sand_parts = {}
wood_parts = {}
fire_parts = {}

all_parts = {}

sand_col = 10
wood_col = 4
fire_col = 8
bg_col =  0



function _init()
  if debug then
    poke(0x5f2d, 1)
  end

  total_rez = 128 * 128
  
  for i=0,total_rez do
    part = {}
    part.x = i % 128
    part.y = i / 128
    add(all_parts, part)
  end
  
end

function _update()

  if debug then
    if stat(34) == 1 then
      -- part = {}
      -- part.x = stat(32)
      -- part.y = stat(33)
      -- add(sand_parts, part)

      part = new_fire_part(stat(32), stat(33))
      add(fire_parts, part)
    elseif stat(34) == 2 then
      part = new_wood_part(stat(32), stat(33))
      part.is_burning = true
      add(wood_parts, part)
    end
  end

  -- sim the sand
  for part in all(sand_parts) do
    if part.y < 127 then
      if pget(part.x, part.y + 1) == bg_col then
	part.y += 1
      elseif pget(part.x + 1, part.y + 1) == bg_col then
	part.x += 1
	part.y += 1
      elseif pget(part.x - 1, part.y + 1) == bg_col then
	part.x -= 1
	part.y += 1 
      end
    end
  end

  -- sim the wood
  for part in all(wood_parts) do
    if part.y < 127 then
      if pget(part.x, part.y + 1) == bg_col then
	part.y += 1
      end

      if part.is_burning then
	fire_part = new_fire_part(part.x, part.y)
	add(fire_parts, fire_part)
	part.burn_time += 1
      end
    end

    if part.burn_time > 100 then
      debug_check += 1
      del(wood_parts, part)
    end
  end

  -- sim the fire
  for part in all(fire_parts) do
    part.y -= 1
    if part.time_in_air > 3 then
      del(fire_parts, part)
    else
      part.time_in_air += 1
    end
  end
end


-- returns true iff there is a solid particle at x,y
function solid_part(x, y)
  return pget(x, y) != bg_col and pget(x, y) != fire_col
end

function new_wood_part(x, y)
  part = {}
  part.x = x
  part.y = y
  part.is_burning = false
  part.burn_time = 0
  return part
end

function new_fire_part(x, y)
  part = {}
  part.x = x
  part.y = y
  part.time_in_air = 0
  return part
end


function _draw()

  cls(0)
--   for part in all(sand_parts) do
--     pset(part.x, part.y, sand_col)
--   end
-- 
--   for part in all(wood_parts) do
--     pset(part.x, part.y, wood_col)
--   end
-- 
--   for part in all(fire_parts) do
--     pset(part.x, part.y, fire_col)
--   end

  for part in all(all_parts) do
    pset(part.x, part.y, 5)
  end


  if debug then
    -- draw cursor
    spr(1, stat(32), stat(33))
    color(0)
    print('wood_parts length: '..#wood_parts)
    print('entered that part '..debug_check)
    print('all_parts length: '..#all_parts)
    print('cpu pct: '..stat(1))

  end

end




__gfx__
00000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000770007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
