local Screen = require 'screen'
local Assert = require 'assert'

local function test_prepare()
  local s = Screen.new()
  s:init({y = 32, x = 32}, 32)
  s:clear()
  return s
end

local function test_line_1()
  local s = test_prepare()
  s:draw_line({y = 1, x = 1}, {y = 16, x = 16})
  Assert.is_true(s:compare('test/img/test1.png'))
end

local function test_line_2()
  local s = test_prepare()
  s:draw_line({y = 16, x = 16}, {y = 1, x = 1})
  Assert.is_true(s:compare('test/img/test1.png'))
end

local function test_line_3()
  local s = test_prepare()
  s:draw_line({y = 15, x = 15}, {y = 1, x = 1})
  Assert.is_false(s:compare('test/img/test1.png'))
end

local function test_tile_to_pixel()
  local y = 10
  local x = 5
  local screen = test_prepare()
  local n = screen:tile_to_pixel({y = y, x = x})
  Assert.is_equal({y = (y - 1) * 25, x = (x - 1) * 25}, n)
end

return function()
  test_line_1()
  test_line_2()
  test_line_3()
  test_tile_to_pixel()
end
