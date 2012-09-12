-- See LICENSE file for copyright and license details

local Misc = require 'misc'

local Enemy = {}
Enemy.__index = Enemy

Enemy.new = function(game)
  local self = {
    _energy_regeneration = 5,
    _type = 'enemy',
    _game = game,
    _pos = {y = 1, x = 1},
    _energy
  }
  return setmetatable(self, Enemy)
end

Enemy.type = function(self)
  return self._type
end

Enemy.energy = function(self)
  return self._energy
end

Enemy.set_energy = function(self, energy)
  self._energy = energy
end

Enemy.regenerate_energy = function(self)
  self._energy = self._energy + self._energy_regeneration
end

Enemy.pos = function(self)
  return self._pos
end

Enemy.set_pos = function(self, pos)
  self._pos = pos
end

Enemy._get_new_pos_simple = function(self)
  local p = Misc.copy(self._pos)
  local destination = self._game:player():pos()
  if destination.x < p.x then
    p.x = p.x - 1
  end
  if destination.x > p.x then
    p.x = p.x + 1
  end
  if destination.y < p.y then
    p.y = p.y - 1
  end
  if destination.y > p.y then
    p.y = p.y + 1
  end
  return p
end

Enemy._get_new_pos_djikstra = function(self)
  local path = self._game:pathfinder():get_path(
      self._pos, self._game:player():pos())
  assert(#path >= 2)
  return path[2]
end

Enemy.callback = function(self)
  if Misc.distance(self._game:player():pos(), self._pos) == 1 then
    self._game:log():add('Enemy attacking you!')
    self._energy = self._energy - self._game:action_cost().fire
    return
  end
  local dist = Misc.distance(self._game:player():pos(), self._pos)
  if dist < self._game:max_see_distance() then
    -- local new_pos = self:_get_new_pos_djikstra()
    local new_pos = self:_get_new_pos_simple()
    if self._game:is_position_free(new_pos) then
      self._game:map():tile(self._pos).unit = nil
      self._pos = new_pos
      self._game:map():tile(self._pos).unit = true
      self._energy = self._energy - self._game:action_cost().move
    else
      self._energy = self._energy - self._game:action_cost().wait
    end
    self._game:map():clamp_pos(self._pos)
  else
    self._energy = self._energy - self._game:action_cost().wait
  end
end

return Enemy
