-- See LICENSE file for copyright and license details

local Misc = require 'misc'

local LogViewer = {}
LogViewer.__index = LogViewer

LogViewer.new = function()
  local self = {
    _pos = {y = 1, x = 1}, -- widget position in pixels
    _screen = nil,
    _log = nil,
    _max_size = 10,
  }
  return setmetatable(self, LogViewer)
end

LogViewer.set_screen = function(self, screen)
  self._screen = screen
end

LogViewer.set_max_size = function(self, max_size)
  self._max_size = max_size
end

LogViewer.set_pos = function(self, pos)
  self._pos = Misc.copy(pos)
end

LogViewer.set_log = function(self, log)
  self._log = log
end

LogViewer.pos = function(self)
  return self._pos
end

LogViewer.draw = function(self)
  local log = self._log
  local strings = log:get_last_strings(self._max_size)
  if not strings then
    return
  end
  local pos = Misc.copy(self._pos)
  local string_height = 11
  for key, string in ipairs(strings) do
    self._screen:draw_text(pos, string)
    pos.y = pos.y + string_height
  end
end

return LogViewer
