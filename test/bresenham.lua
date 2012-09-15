local Assert = require 'assert'
local Bresenham = require 'bresenham'

local function test_bresenham()
  local a = {y = 1, x = 1}
  local b = {y = 2, x = 2}
  local c = {y = 3, x = 3}
  local d = {y = 5, x = 3}
  local a_d = {
    a,
    {y = 2, x = 1},
    {y = 3, x = 2},
    {y = 4, x = 2},
    d
  }
  Assert.is_equal(Bresenham.line(a, a), {a})
  Assert.is_equal(Bresenham.line(a, b), {a, b})
  Assert.is_equal(Bresenham.line(c, b), {c, b})
  Assert.is_equal(Bresenham.line(a, d), a_d)
end

return function()
  test_bresenham()
end
