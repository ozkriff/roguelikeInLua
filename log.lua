-- See LICENSE file for copyright and license details

local Misc = require 'misc'

local function new()
  local self = {}
  local strings = {}
  local max_size = 10
  local pos = {y = 1, x = 1}
  local screen
  self.draw = function()
    local i = 1
    while strings[i] and i <= max_size do
      screen:px_print(
          pos.y + i * 10, pos.x,
          strings[i])
      i = i + 1
    end
  end
  self.add = function(string)
    table.insert(strings, 1, string)
  end
  self.set_screen = function(new_screen)
    screen = new_screen
  end
  self.set_max_size = function(new_max_size)
    max_size = new_max_size
  end
  self.set_pos = function(new_pos)
    pos = Misc.deepcopy(new_pos)
  end
  self.pos = function()
    return pos
  end
  return self
end

return { new = new }
