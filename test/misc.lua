local Assert = require 'assert'
local Misc = require 'misc'

local dir = {
  a = {y = 2, x = 2},
  up = {y = 1, x = 2},
  up_right = {y = 1, x = 3},
  right = {y = 2, x = 3},
  down_right = {y = 3, x = 3},
  down = {y = 3, x = 2},
  down_left = {y = 3, x = 1},
  left = {y = 2, x = 1},
  up_left = {y = 1, x = 1}
}

local function test_round()
  local tests = {
    {0, 0},
    {0.1, 0},
    {0.4, 0},
    {0.5, 1},
    {0.6, 1},
    {1, 1},
    {1.0, 1},
    {1.1, 1},
    {2.455, 2},
    {2.51, 3},
    {-0.3, 0},
    {-0.9, -1},
    {-2.51, -3},
  }
  for k, v in ipairs(tests) do
    Assert.is_equal(Misc.round(v[1]), v[2])
  end
end

local function test_distance()
  local a = {y = 1, x = 1}
  local b = {y = 1, x = 2}
  local c = {y = 2, x = 2}
  local d = {y = 2, x = 3}
  local e = {y = 3, x = 3}
  local f = {y = 4, x = 4}
  Assert.is_equal(Misc.distance(a, a), 0)
  Assert.is_equal(Misc.distance(a, b), 1)
  Assert.is_equal(Misc.distance(a, c), 1)
  Assert.is_equal(Misc.distance(a, d), 2)
  Assert.is_equal(Misc.distance(a, e), 3)
  Assert.is_equal(Misc.distance(a, f), 4)
end

-- TODO add more tests
local function test_to_string()
  Assert.is_equal(Misc.to_string(1), '1')
  Assert.is_equal(Misc.to_string(), 'nil')
  Assert.is_equal(Misc.to_string(nil), 'nil')
  Assert.is_equal(Misc.to_string(1 + 4), '5')
  Assert.is_equal(Misc.to_string({3}), '\'3\'\n')
  -- Assert.is_equal(Misc.to_string({3, 4}), '\'3\'\n')
end

local function test_dump()
  Assert.is_equal(Misc.dump(1), '1')
  Assert.is_equal(Misc.dump(nil), 'nil')
  Assert.is_equal(Misc.dump({}), '{ } ')
  Assert.is_equal(Misc.dump({a, b}), '{ } ')
  Assert.is_equal(Misc.dump({a = 7}),
      '{ [\'a\'] = 7, } ')
  Assert.is_equal(Misc.dump({a = 1, b = 2}),
      '{ [\'a\'] = 1, [\'b\'] = 2, } ')
  Assert.is_equal(Misc.dump({a = {1, b = 2}}),
      '{ [\'a\'] = { [1] = 1, [\'b\'] = 2, } , } ')
end

local function test_int_to_char()
  Assert.is_equal(Misc.int_to_char(65), 'A')
  Assert.is_equal(Misc.int_to_char(66), 'B')
  Assert.is_equal(Misc.int_to_char(97), 'a')
end

local function test_neib()
  Assert.is_equal(Misc.neib(dir.a, 1), dir.up)
  Assert.is_equal(Misc.neib(dir.a, 2), dir.up_right)
  Assert.is_equal(Misc.neib(dir.a, 3), dir.right)
  Assert.is_equal(Misc.neib(dir.a, 4), dir.down_right)
  Assert.is_equal(Misc.neib(dir.a, 5), dir.down)
  Assert.is_equal(Misc.neib(dir.a, 6), dir.down_left)
  Assert.is_equal(Misc.neib(dir.a, 7), dir.left)
  Assert.is_equal(Misc.neib(dir.a, 8), dir.up_left)
end

local function test_m2dir()
  local distant_point = {y = 4, x = 4}
  Assert.is_equal(Misc.m2dir(dir.a, dir.up), 1)
  Assert.is_equal(Misc.m2dir(dir.a, dir.up_right), 2)
  Assert.is_equal(Misc.m2dir(dir.a, dir.right), 3)
  Assert.is_equal(Misc.m2dir(dir.a, dir.down_right), 4)
  Assert.is_equal(Misc.m2dir(dir.a, dir.down), 5)
  Assert.is_equal(Misc.m2dir(dir.a, dir.down_left), 6)
  Assert.is_equal(Misc.m2dir(dir.a, dir.left), 7)
  Assert.is_equal(Misc.m2dir(dir.a, dir.up_left), 8)
  Assert.is_nil(Misc.m2dir(dir.a, distant_point))
  Assert.is_nil(Misc.m2dir(dir.a, dir.a))
end

local function test_id_to_key()
  local t = {
    {id = 1},
    [7] = {id = 2},
    ['test'] = {id = 9},
    [-1] = {id = 'string'}
  }
  Assert.is_equal(Misc.id_to_key(t, 1), 1)
  Assert.is_equal(Misc.id_to_key(t, 2), 7)
  Assert.is_equal(Misc.id_to_key(t, 9), 'test')
  Assert.is_equal(Misc.id_to_key(t, 'string'), -1)
end

local function test_compare()
  local a = {1, 2, 3}
  local b = {1, 2, 3}
  local c = {1, 2, 3, 4}
  local d = {1, 2}
  local e = {1, 2, {3, 'ff'}, 4}
  local f = {1, 2, {3, 'ff'}, 4}
  local g = {1, 2, {3, 'ff', {}}, 4}
  local empty = {}
  Assert.is_true(Misc.compare(a, b))
  Assert.is_false(Misc.compare(a, c))
  Assert.is_false(Misc.compare(a, d))
  Assert.is_false(Misc.compare(a, nil))
  Assert.is_false(Misc.compare(empty, nil))
  Assert.is_true(Misc.compare(nil, nil))
  Assert.is_true(Misc.compare(e, f))
  Assert.is_false(Misc.compare(e, g))
end

local function test_copy()
  local a = {1, 2, 3}
  local b = Misc.copy(a)
  Assert.is_equal(a, b)
  b[1] = 4
  Assert.is_equal(a[1], 1)
end

local function test_clamp()
  Assert.is_equal(Misc.clamp(0, 0, 0), 0)
  Assert.is_equal(Misc.clamp(1, 0, 0), 0)
  Assert.is_equal(Misc.clamp(1, 0, 1), 1)
  Assert.is_equal(Misc.clamp(-1, 0, 1), 0)
  Assert.is_equal(Misc.clamp(100, 0, 9), 9)
  Assert.is_equal(Misc.clamp(100, 200, 300), 200)
end

return function()
  test_round()
  test_distance()
  test_to_string()
  test_dump()
  test_int_to_char()
  test_neib()
  test_m2dir()
  test_id_to_key()
  test_compare()
  test_copy()
  test_clamp()
end
