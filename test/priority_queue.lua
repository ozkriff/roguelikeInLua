local Assert = require 'assert'
local PriorityQueue = require 'priority_queue'

local function test_priority_queue()
  local queue = PriorityQueue.new()
  Assert.is_true(queue:is_empty())
  queue:push('[1]', 1)
  queue:push('[2]', 5)
  queue:push('[3]', 5)
  queue:push('[4]', 3)
  Assert.is_equal(queue:pop(), '[2]')
  Assert.is_equal(queue:pop(), '[3]')
  Assert.is_equal(queue:pop(), '[4]')
  Assert.is_equal(queue:pop(), '[1]')
  Assert.is_true(queue:is_empty())
  queue:push('[1]', -1)
  queue:push('[2]', -5)
  queue:push('[3]', -3)
  Assert.is_equal(queue:pop(), '[1]')
  Assert.is_equal(queue:pop(), '[3]')
  Assert.is_equal(queue:pop(), '[2]')
  Assert.is_true(queue:is_empty())
end

return function()
  test_priority_queue()
end
