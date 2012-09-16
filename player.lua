-- See LICENSE file for copyright and license details

local Misc = require 'misc'
local Bresenham = require 'bresenham'

local Player = {}
Player.__index = Player

Player.new = function(game)
  local self = {
    _energy_regeneration = 10,
    _type = 'player',
    _game = game,
    _pos = {y = 1, x = 1},
    _energy
  }
  return setmetatable(self, Player)
end

local key_to_dir_map = {
  h = 'left',
  j = 'down',
  k = 'up',
  l = 'right',
  y = 'up_left',
  u = 'up_right',
  b = 'down_left',
  n = 'down_right'
}

local direction_to_diff_map = {
  up = {x = 0, y = -1},
  up_right = {x = 1, y = -1},
  right = {x = 1, y = 0},
  down_right = {x = 1, y = 1},
  down = {x = 0, y = 1},
  down_left = {x = -1, y = 1},
  left = {x = -1, y = 0},
  up_left = {x = -1, y = -1},
}

Player.type = function(self)
  return self._type
end

Player.energy = function(self)
  return self._energy
end

Player.set_energy = function(self, energy)
  self._energy = energy
end

Player.regenerate_energy = function(self)
  self._energy = self._energy + self._energy_regeneration
end

Player.pos = function(self)
  return self._pos
end

Player.set_pos = function(self, pos)
  self._pos = pos
end

-- TODO
Player._fire = function(self)
  local g = self._game -- shortcut
  local char = ' '
  local cursor_pos = Misc.copy(self._pos)
  while char ~= 'f' do
    local dir = key_to_dir_map[char]
    if dir then
      local diff = direction_to_diff_map[dir]
      cursor_pos.x = cursor_pos.x + diff.x
      cursor_pos.y = cursor_pos.y + diff.y
      cursor_pos = g:map():clamp_pos(cursor_pos)
    end
    g:set_target_position(cursor_pos)
    g:draw()
    char = g:get_next_command()
  end
  g:set_target_position(nil)
  local enemy = g:unit_at(cursor_pos)
  if not enemy then
    g:log():add('No one here!')
    return
  end
  if not Bresenham.los(self._pos, cursor_pos,
      function(pos)
        return g:map():tile(pos).type == 'empty'
      end)
  then
    g:log():add('Obstacle!')
    return
  end
  g:log():add('firing')
  self._energy = self._energy - g:action_cost().fire
  local d = Misc.distance(self._pos, enemy:pos())
  g:kill_unit(enemy.id)
end

Player._move = function(self, direction)
  local g = self._game -- shortcut
  local new_pos = {
    y = self._pos.y + direction_to_diff_map[direction].y,
    x = self._pos.x + direction_to_diff_map[direction].x
  }
  new_pos = g:map():clamp_pos(new_pos)
  if g:is_position_free(new_pos) then
    g:map():tile(self._pos).unit = nil
    self._pos = new_pos
    g:map():tile(self._pos).unit = true
    g:update_fov()
    g:log():add('moved ' .. direction)
    self._energy = self._energy - g:action_cost().move
  else
    g:log():add('waiting')
    self._energy = self._energy - g:action_cost().wait
  end
end

Player._scroll_map = function(self)
  repeat
    local char = self.game:get_next_command()
    local dir = key_to_dir_map[char]
    if dir then
      local old = self._game:screen():get_map_offset()
      local diff = direction_to_diff_map[dir]
      assert(diff)
      old.y = old.y - diff.y * 25 * 2
      old.x = old.x - diff.x * 25 * 2
      self._game:screen():set_map_offset(old)
      self._game:draw()
    end
  until char == 'm' or char == 'q'
end

Player._do_command = function(self, char)
  if char == 'q' then
    self._game:set_is_running(false)
  elseif key_to_dir_map[char] then
    self:_move(key_to_dir_map[char])
  elseif char == '.' then
    self._game:log():add('waiting')
    self._energy = self._energy - self._game:action_cost().wait
  elseif char == 'f' then
    self:_fire()
  elseif char == 'm' then
    self:_scroll_map()
  end
end

Player.callback = function(self)
  self._game:draw()
  self:_do_command(self.game:get_next_command())
end

return Player
