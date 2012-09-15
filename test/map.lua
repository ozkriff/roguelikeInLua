local Assert = require 'assert'
local Map = require 'map'

local function test_creation()
  local map = Map.new()
  Assert.is_true(map ~= nil)
end

local function test_set_get_size()
  local map = Map.new()
  local size = {y = 10, x = 7}
  map:set_size(size)
  Assert.is_equal(map:size(), size)
  size.x = 3
  Assert.is_equal(map:size(), {y = 10, x = 7})
end

local function test_is_inboard()
  local map = Map.new()
  local size = {y = 10, x = 7}
  map:set_size(size)
  Assert.is_false(map:is_inboard({y = 0, x = 0}))
  Assert.is_true(map:is_inboard({y = 1, x = 1}))
  Assert.is_true(map:is_inboard({y = 10, x = 7}))
  Assert.is_true(map:is_inboard({y = 3, x = 4}))
  Assert.is_false(map:is_inboard({y = 11, x = 7}))
  Assert.is_false(map:is_inboard({y = 10, x = 8}))
end

local function test_clamp_pos()
  local size = {y = 10, x = 7}
  local p11 = {y = 0, x = 0}
  local p12 = {y = 1, x = 1}
  local p21 = {y = 100, x = 1}
  local p22 = {y = 10, x = 1}
  local p31 = {y = 1, x = 100}
  local p32 = {y = 1, x = 7}
  local p41 = {y = 3, x = 5}
  local p42 = {y = 3, x = 5}
  local map = Map.new()
  map:set_size(size)
  Assert.is_equal(map:clamp_pos(p11), p12)
  Assert.is_equal(map:clamp_pos(p21), p22)
  Assert.is_equal(map:clamp_pos(p31), p32)
  Assert.is_equal(map:clamp_pos(p41), p42)
end

local function test_get_random_pos()
  local size = {y = 10, x = 7}
  local map = Map.new()
  map:set_size(size)
  for i = 1, 99 do
    local p = map:get_random_pos()
    Assert.is_true(p.x >= 1)
    Assert.is_true(p.y >= 1)
    Assert.is_true(p.x <= size.x)
    Assert.is_true(p.y <= size.y)
  end
end

local function test_tile()
  local size = {y = 10, x = 7}
  local map = Map.new()
  map:set_size(size)
  Assert.is_true(map:tile({y = 2, x = 3}).type, 'empty')
  map:tile({y = 2, x = 3}).type = 'block'
  Assert.is_true(map:tile({y = 2, x = 3}).type, 'block')
end

return function()
  test_creation()
  test_set_get_size()
  test_is_inboard()
  test_clamp_pos()
  test_get_random_pos()
  test_tile()
end
