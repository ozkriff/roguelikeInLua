-- See LICENSE file for copyright and license details

local Misc = require 'misc'

local Log = {}
Log.__index = Log

Log.new = function()
  local self = {
    _strings = {},
    _max_size = 10,
    _pos = {y = 1, x = 1},
    _screen
  }
  return setmetatable(self, Log)
end

Log.draw = function(self)
  local i = 1
  while self._strings[i] and i <= self._max_size do
    self._screen:draw_text(
        self._pos.y + i * 10, self._pos.x,
        self._strings[i])
    i = i + 1
  end
end

Log.add = function(self, string)
  table.insert(self._strings, 1, string)
end

Log.set_screen = function(self, screen)
  self._screen = screen
end

Log.set_max_size = function(self, new_max_size)
  self._max_size = max_size
end

Log.set_pos = function(self, pos)
  self._pos = Misc.copy(pos)
end

Log.pos = function(self)
  return self._pos
end

return Log
