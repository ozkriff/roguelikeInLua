-- See LICENSE file for copyright and license details

local Misc = require 'misc'
local Symbols = require 'symbols'

local Map = {}
Map.__index = Map

Map.new = function()
  local self = {
    _tiles,
    _size = {y = 0, x = 0},
    _screen
  }
  return setmetatable(self, Map)
end

Map.tile = function(self, pos)
  return self._tiles[pos.y][pos.x]
end

Map.set_size = function(self, size)
  self._size = Misc.copy(size)
  self._tiles = {}
  for y = 1, self._size.y do
    self._tiles[y] = {}
    for x = 1, self._size.x do
      self._tiles[y][x] = {
        type = 'empty',
        unit = nil,
        is_seen = false,
        cost = math.huge,
        parent = 1 -- TODO: ?
      }
    end
  end
end

Map.size = function(self)
  return self._size
end

-- TODO extract draw() to map_viewer object
Map.draw = function(self)
  local type_to_char_map = {
    ['empty'] = Symbols.POINT,
    ['block'] = Symbols.HASH
  }
  for y = 1, self._size.y do
    self._screen:move({y = y, x = 1})
    for x = 1, self._size.x do
      local pos = {y = y, x = x}
      self._screen:move(pos)
      local t = self:tile(pos)
      local c = type_to_char_map[t.type]
      if not t.unit and t.is_seen then
        self._screen:draw_symbol(c)
      end
    end
  end
end

Map.clamp_pos = function(self, pos)
  pos.x = Misc.clamp(pos.x, 1, self._size.x)
  pos.y = Misc.clamp(pos.y, 1, self._size.y)
end

Map.is_inboard = function(self, pos)
  assert(pos)
  if pos.y < 1 then
    return false
  end
  if pos.x < 1 then
    return false
  end
  if pos.y > self._size.y then
    return false
  end
  if pos.x > self._size.x then
    return false
  end
  return true
end

Map.is_tile_free = function(self, pos)
  return self:tile(pos).type == 'empty'
end

Map.get_random_pos = function(self)
  return {
    y = math.random(1, self._size.y),
    x = math.random(1, self._size.x)
  }
end

Map.set_screen = function(self, new_screen)
  self._screen = new_screen
end

return Map
