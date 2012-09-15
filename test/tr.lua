local Assert = require 'assert'
local Tr = require 'tr'

local function test_tr()
  local tr = Tr('rus')
  Assert.is_equal(tr'Hi', 'Привет')
  Assert.is_equal(tr'Bye', 'Пока')
  Assert.is_equal(tr'What', 'What')
end

return function()
  test_tr()
end
