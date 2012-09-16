-- See LICENSE file for copyright and license details

local Assert = require 'assert'
local Log = require 'log'

local function test_get_strings()
  local log = Log.new()
  local strings_count = 100
  for i = 1, strings_count do
    log:add('string_' .. i)
  end
  Assert.is_equal(log:get_last_strings(3),
      {
        'string_' .. strings_count,
        'string_' .. strings_count - 1,
        'string_' .. strings_count - 2,
      })
  Assert.is_equal(log:get_last_strings(-1), {})
  Assert.is_equal(log:get_last_strings(1),
      {'string_' .. strings_count})
  Assert.is_nil(log:get_last_strings())
end

return function()
  test_get_strings()
end
