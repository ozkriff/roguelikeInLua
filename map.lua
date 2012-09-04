-- See LICENSE file for copyright and license details

local Symbols = require 'symbols'
local Misc = require 'misc'

return function()
  local self = {}
  local size = {y = 0, x = 0}
  local screen

  self.set_size = function(new_size)
    size = Misc.deepcopy(new_size)
    for y = 1, size.y do
      self[y] = {}
      for x = 1, size.x do
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

  self.size = function()
    return size
  end

  -- TODO: scrolling
  -- TODO extract draw() to map_viewer object
  self.draw = function()
    local type_to_char_map = {
      ['empty'] = Symbols.POINT,
      ['block'] = Symbols.HASH
    }
    -- screen:move(pos.y, pos.x)
    for y = 1, size.y do
      screen:move(y, 1)
      for x = 1, size.x do
        screen:move(y, x)
        local c = type_to_char_map[self[y][x].type]
        if not self[y][x].unit and self[y][x].is_seen then
          screen:printf(c)
        end
      end
      -- screen:move(pos.y + y, pos.x)
    end
  end

  self.clamp_pos = function(pos)
    if pos.x < 1 then
      pos.x = 1
    elseif pos.x > size.x then
      pos.x = size.x
    end
    if pos.y < 1 then
      pos.y = 1
    elseif pos.y > size.y then
      pos.y = size.y
    end
  end

  self.is_tile_free = function(pos)
    return self[pos.y][pos.x].type == 'empty'
  end

  self.get_random_pos = function()
    return {
      y = math.random(1, size.y),
      x = math.random(1, size.x)
    }
  end

  self.set_screen = function(new_screen)
    screen = new_screen
  end

  return self
end
