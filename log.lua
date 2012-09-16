-- See LICENSE file for copyright and license details

local Misc = require 'misc'

local Log = {}
Log.__index = Log

Log.new = function()
  local self = {
    _strings = {},
  }
  return setmetatable(self, Log)
end

Log.get_last_strings = function(self, count)
  local strings = {}
  if not count or count == 0 then
    return nil
  end
  for i = 1, count do
    table.insert(strings, self._strings[i])
  end
  return strings
end

Log.add = function(self, string)
  table.insert(self._strings, 1, string)
end

return Log
