-- See LICENSE file for copyright and license details

local Symbols = require 'symbols'

local Map = {}
Map.__index = Map

function Map.new()
  local new_map = {}
  return setmetatable(new_map, Map)
end

function Map:set_size(size)
  self.size = size
  for y = 1, self.size.y do
    self[y] = {}
    for x = 1, self.size.x do
      self[y][x] = {
        type = 'empty',
        unit = nil,
        is_seen = false,
        cost = math.huge,
        parent_dir = 1 -- TODO: ?
      }
    end
  end
end

-- TODO: scrolling
-- TODO extract draw() to map_viewer object
function Map:draw()
  local type_to_char_map = {
    ['empty'] = Symbols.POINT,
    ['block'] = Symbols.HASH
  }
  -- self.screen:move(self.pos.y, self.pos.x)
  for y = 1, self.size.y do
    self.screen:move(y, 1)
    for x = 1, self.size.x do
      self.screen:move(y, x)
      local c = type_to_char_map[self[y][x].type]
      if not self[y][x].unit and self[y][x].is_seen then
        self.screen:printf(c)
      end
    end
    -- self.screen:move(self.pos.y + y, self.pos.x)
  end
end

function Map:clamp_pos(pos)
  if pos.x < 1 then
    pos.x = 1
  elseif pos.x > self.size.x then
    pos.x = self.size.x
  end
  if pos.y < 1 then
    pos.y = 1
  elseif pos.y > self.size.y then
    pos.y = self.size.y
  end
end

function Map:is_tile_free(pos)
  return self[pos.y][pos.x].type == 'empty'
end

function Map:get_random_pos()
  return {
    y = math.random(1, self.size.y),
    x = math.random(1, self.size.x)
  }
end

return Map
