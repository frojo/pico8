pico-8 cartridge // http://www.pico-8.com
version 18
__lua__


function _init()
  yuzhu = m_yuzhu()

  timer = 0
  manager = m_manager()

  words = {}
  burgers = {}
end

function m_yuzhu()
  local yuzhu = {}
  yuzhu.x = 50
  yuzhu.y = 50
  yuzhu.dx = 0
  yuzhu.dy = 0

  yuzhu.anim = {}
  -- either idling or running
  yuzhu.anim.is_idle = true
  -- used for flipping sprites for animation
  yuzhu.anim.timer = 0
  yuzhu.anim.flipped = false

  yuzhu.word_cooldown = 0

  yuzhu.burger_mode = false
  yuzhu.burger_mode_timer = 5*60
  yuzhu.burger_mode_word_col = 4

  yuzhu.grounded = function(self)
    return fget(mget(yuzhu.x/8, yuzhu.y/8+1), 0)
  end

  yuzhu.shoot_word = function(self, col)
    yuzhu.word_cooldown = 10
    add(words, m_word(yuzhu, col))
  end

  yuzhu.update = function(self)
    -- horizontal movement (including bounds)
    self.dx = 0
    if btn(0) and self.x > -2 then
      self.dx = -1
    elseif btn(1) and self.x < 122 then
      self.dx = 1
    end

    -- vertical movement (including jump)
    if btn(2) and self:grounded() then
      -- jump
      self.dy = -2
    elseif self:grounded() then
      self.dy = 0
    else
      self.dy += .1
    end
    -- don't let her fall too fast
    self.dy = min(self.dy, 1.8)


    if btn(5) then
      if self.burger_mode then
	if rnd(1) < .1 then
	  self.burger_mode_word_col = flr(rnd(16))
	end
	self:shoot_word(self.burger_mode_word_col)
      else
	if self.word_cooldown == 0 then
	  self:shoot_word(0)
	end
      end
    end
    if self.word_cooldown > 0 then self.word_cooldown -= 1 end

    -- update animation things
    local idle_this_frame = self:grounded() and self.dx == 0
    if idle_this_frame and not self.anim.is_idle then
      -- yuhzu was running last frame and is idle now
      self.anim.timer = 0
    elseif not idle_this_frame and self.anim.is_idle then
      -- yuhzu was idle last frame is running now
      self.anim.timer = 0
    end
    self.anim.is_idle = idle_this_frame
    self.anim.timer += 1

    if self.dx < 0 then
      self.anim.flipped = false
    elseif self.dx > 0 then
      self.anim.flipped = true
    end

    self.y += self.dy
    self.x += self.dx

    if self.burger_mode then
      if self.burger_mode_timer <= 0 then
	self.burger_mode = false
	manager.burger_timer = 60
      end
      self.burger_mode_timer -= 1
    end

  end

  yuzhu.enter_burger_mode = function(self)
    self.burger_mode = true
    self.burger_mode_timer = 5*60
  end

  yuzhu.draw_idle = function(self)
    if flr(self.anim.timer / 30) % 2 == 0 then
      spr(1, self.x, self.y, 1, 1, self.anim.flipped)
    else
      spr(2, self.x, self.y, 1, 1, self.anim.flipped)
    end
  end

  yuzhu.draw_running = function(self)
    if flr(self.anim.timer / 4) % 2 == 0 then
      spr(3, self.x, self.y, 1, 1, self.anim.flipped)
    else
      spr(4, self.x, self.y, 1, 1, self.anim.flipped)
    end
  end

  yuzhu.draw_skipping = function(self)
    if self:grounded() then
      -- if on the ground, do the skipping sequence
      local frame = self.anim.timer % 20
      if frame >= 0 and frame < 4 then
	spr(5, self.x, self.y, 1, 1, self.anim.flipped)
      elseif frame >= 4 and frame < 15 then
	spr(5, self.x, self.y - 1, 1, 1, self.anim.flipped)
      elseif frame >= 15 and frame < 20 then
	spr(6, self.x, self.y, 1, 1, self.anim.flipped)
      end
    else
      -- if airborne, just keep the knee up
      spr(5, self.x, self.y - 1, 1, 1, self.anim.flipped)
    end

  end

  yuzhu.draw = function(self)
    -- draw yuzhu
    -- use better blue
    pal(12, 140, 1)
    -- make black not transparent, and set white to transparent
    palt(0, false)
    palt(7, true)

    if self:grounded() and yuzhu.dx == 0 then
      self:draw_idle()
    else
      if self.burger_mode then
	self:draw_skipping()
      else
	self:draw_running()
      end
    end
    pal()
  end

  return yuzhu
end

function m_manager()
  local manager = {}

  manager.num_burgers = 0
  manager.burger_timer = 1

  manager.burger_spn_pts = {80, 80, 100, 100}

  manager.spawn_burger = function(self)
    self.num_burgers += 1
    add(burgers, m_burger(self.burger_spn_pts[1], self.burger_spn_pts[2]))
  end

  manager.remove_burger = function(self, burger)
    self.num_burgers -= 1
    del(burgers, burger)

    -- reset burger spawn timer
    self.burger_timer = 300
  end

  manager.update = function(self)
    if self.burger_timer > 0 then self.burger_timer -= 1 end

    if self.burger_timer == 0 and self.num_burgers < 1 then
      self:spawn_burger()
    end
  end

  return manager
end


function _draw()
  cls()

  -- draw level
  palt(0, false)
  map(0, 0, 0, 0, 16, 16)
  pal()

  yuzhu:draw()

  for word in all(words) do
    word:draw()
  end
  for burger in all(burgers) do
    burger:draw()
  end

  -- debug prints
  print(yuzhu.burger_mode, 0, 0, 8)
end

function screen_to_map(screen_pos)
  return screen_pos*8
end


function m_burger(x, y)
  local burger = {}

  burger.x = x
  burger.y = y

  burger.draw = function(self)
    spr(18, self.x, self.y + 1.5*sin(timer/40))
  end

  burger.update = function(self)
    if abs(yuzhu.x - self.x) < 5 and (yuzhu.y - self.y) < 3 then
      -- yuzhu eats burger

      manager:remove_burger(self)
      yuzhu:enter_burger_mode()
    end
  end

  return burger
end

function m_word(yuzhu, col)
  local word = {}

  word.text = 'plum'
  word.x = yuzhu.x
  word.y = yuzhu.y
  word.col = col

  if yuzhu.anim.flipped then
    word.x += 5
    word.dx = 1.5
  else
    word.x -= 7 + #word.text
    word.dx = -1.5
  end
  
  -- set some random dy offset
  word.dy = rnd(.5)
  if rnd(2) > 1 then word.dy = -word.dy end

  word.life_timer = 1000

  word.update = function(self)
    self.x += self.dx
    self.y += self.dy
    if self.life_timer <= 0 then
      del(words, self)
    end
    self.life_timer -= 1
  end

  word.draw = function(self)
    print(self.text, self.x, self.y, self.col)
  end

  return word
end


function _update()

  yuzhu:update()
  for word in all(words) do
    word:update()
  end
  for burger in all(burgers) do
    burger:update()
  end
  manager:update()

  timer += 1
end
__gfx__
00000000770000077777777777000007770000077700000777000007000000000000000000000000000000000000000000000000000000000000000000000000
0000000077ccc0077700000777ccc00777ccc00777ccc00777ccc007000000000000000000000000000000000000000000000000000000000000000000000000
00700700770c0c0777ccc007770c0c07770c0c07770c0c07770c0c07000000000000000000000000000000000000000000000000000000000000000000000000
00077000770c0c07770c0c07770c0c07770c0c07770c0c07770c0c07000000000000000000000000000000000000000000000000000000000000000000000000
0007700077cccc07770c0c0777cccc0777cccc0777cccc0777cccc07000000000000000000000000000000000000000000000000000000000000000000000000
007007007770007777cccc0777700077777000777770007777700077000000000000000000000000000000000000000000000000000000000000000000000000
00000000777000777770007777b00077777000b7777b007777700077000000000000000000000000000000000000000000000000000000000000000000000000
00000000777b7b77777b7b7777777b77777b77777777b777777b7777000000000000000000000000000000000000000000000000000000000000000000000000
ffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffff000000000099999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffff0000000000aaaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffff000000000044444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffff000000000099999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000001111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
