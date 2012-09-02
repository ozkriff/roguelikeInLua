-- See LICENSE file for copyright and license details

local Log = {}
Log.__index = Log

function Log.new()
  local new_log = {
    strings = {},
    n = 1
  }
  return setmetatable(new_log, Log)
end

function Log:draw()
  local i = 1
  while self.strings[i] and i <= self.max_size do
    self.screen:px_print(
        self.pos.y + i * 10, self.pos.x,
        self.strings[i])
    i = i + 1
  end
end

function Log:add(string)
  table.insert(self.strings, 1, string)
  -- table.insert(self.strings, 1, self.n .. ': ' .. string)
  -- print('LOG DEBUG: ' .. string)
  self.n = self.n + 1
end

return Log
