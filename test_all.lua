#!env lua
-- See LICENSE file for copyright and license details

local Tr = require 'tr'
local Log = require 'log'
local Map = require 'map'
local Game = require 'game'
local Misc = require 'misc'
local Assert = require 'assert'
local Screen = require 'screen'
local Symbols = require 'symbols'
local Bresenham = require 'bresenham'
local Pathfinder = require 'pathfinder'
local TimeSystem = require 'time_system'
local PriorityQueue = require 'priority_queue'

local function test_unittype_to_char()
  local game = Game.new()
  Assert.is_equal(game.unit_type_to_char('player'), Symbols.AT)
  Assert.is_equal(game.unit_type_to_char('enemy'), Symbols.Z)
  Assert.is_nil(game.unit_type_to_char('ololo'))
end

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
local function test_misc_to_string()
  Assert.is_equal(Misc.to_string(1), '1')
  Assert.is_equal(Misc.to_string(), 'nil')
  Assert.is_equal(Misc.to_string(nil), 'nil')
  Assert.is_equal(Misc.to_string(1 + 4), '5')
  Assert.is_equal(Misc.to_string({3}), '\'3\'\n')
  -- Assert.is_equal(Misc.to_string({3, 4}), '\'3\'\n')
end

-- TODO add more tests
local function test_misc_dump()
  Assert.is_equal(Misc.dump(1), '1')
  Assert.is_equal(Misc.dump(nil), 'nil')
  Assert.is_equal(Misc.dump({}), '{ } ')
  -- Assert.is_equal(Misc.dump({abc, cde}), '{abc, } ')
end

local function test_int_to_char()
  Assert.is_equal(Misc.int_to_char(65), 'A')
  Assert.is_equal(Misc.int_to_char(66), 'B')
  Assert.is_equal(Misc.int_to_char(97), 'a')
end

local function test_map()
  -- TODO
  local map = Map.new()
  map:set_size({y = 10, x = 10})
  map.pos = {y = 1, x = 1}
end

local function test_time_system()
  local buffer = ''
  local function create_mock_actor(id, energy_regeneration)
    return {
      _energy = 0,
      _energy_regeneration = energy_regeneration,
      id = id,
      regenerate_energy = function(self)
        self._energy = self._energy + self._energy_regeneration
      end,
      set_energy = function(self, energy)
        self._energy = self._energy + energy
      end,
      energy = function(self)
        return self._energy
      end,
      callback = function(self)
        buffer = buffer .. tostring(self.id)
        self._energy = self._energy - 20
      end
    }
  end
  local time_system = TimeSystem.new()
  time_system:add_actor(create_mock_actor(1, 10), 1)
  time_system:add_actor(create_mock_actor(2, 5), 2)
  for i = 1, 21 do
    buffer = buffer .. '{'
    time_system:step()
    buffer = buffer .. '}'
  end
  Assert.is_equal(buffer, '{12}' .. string.rep('{1}{}{12}{}', 5))
end

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

local function test_pathfinder()
  function prepare_map()
    local tiles_cost = {
      {1, 1, 1, 9, 1},
      {1, 1, 9, 9, 1},
      {1, 9, 1, 1, 1},
      {3, 9, 1, 9, 9},
      {1, 9, 1, 1, 1},
    }
    local map_size = {y = 5, x = 5}

    -- Generate actual map from tiles_cost array
    local map = {
      size = {y = map_size.y, x = map_size.x},
    }
    for y = 1, map_size.y do
      map[y] = {}
      for x = 1, map_size.x do
        map[y][x] = {
          cost = tiles_cost[y][x],
          current_cost = 3000,
          parent = 1
        }
      end
    end
    return map
  end
  local pathfinder = Pathfinder.new(prepare_map())
  local a = {y = 1, x = 1}
  local b = {y = 1, x = 2}
  local c = {y = 4, x = 1}
  local d = {y = 1, x = 5}
  local e = {y = 5, x = 5}
  Assert.is_equal(pathfinder:get_path(a, a), {a})
  Assert.is_equal(pathfinder:get_path(a, b), {a, b})
  Assert.is_equal(pathfinder:get_path(a, c),
      {a, {y = 2, x = 1}, {y = 3, x = 1}, c})
  Assert.is_equal(pathfinder:get_path(d, e),
      {
        d,
        {y = 2, x = 5},
        {y = 3, x = 4},
        {y = 4, x = 3},
        {y = 5, x = 4},
        e,
      }
  )
end

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

local function test_misc_neib()
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

local function test_misc_id_to_key()
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

local function test_misc_compare()
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

local function test_misc_copy()
  local a = {1, 2, 3}
  local b = Misc.copy(a)
  Assert.is_equal(a, b)
  b[1] = 4
  Assert.is_equal(a[1], 1)
end

local function test_tr()
  local tr = Tr('rus')
  Assert.is_equal(tr'Hi', 'Привет')
  Assert.is_equal(tr'Bye', 'Пока')
  Assert.is_equal(tr'What', 'What')
end

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

local function test_clamp()
  Assert.is_equal(Misc.clamp(0, 0, 0), 0)
  Assert.is_equal(Misc.clamp(1, 0, 0), 0)
  Assert.is_equal(Misc.clamp(1, 0, 1), 1)
  Assert.is_equal(Misc.clamp(-1, 0, 1), 0)
  Assert.is_equal(Misc.clamp(100, 0, 9), 9)
  Assert.is_equal(Misc.clamp(100, 200, 300), 200)
end

local function test_screen_prepare()
  local s = Screen.new()
  s:init({y = 32, x = 32}, 32)
  s:clear()
  return s
end

-- TODO: Rename test images
local function test_screen_line_1()
  local s = test_screen_prepare()
  s:draw_line({y = 1, x = 1}, {y = 16, x = 16})
  Assert.is_true(s:compare('img/tests/test1.png'))
end

local function test_screen_line_2()
  local s = test_screen_prepare()
  s:draw_line({y = 16, x = 16}, {y = 1, x = 1})
  Assert.is_true(s:compare('img/tests/test1.png'))
end

local function test_screen_line_3()
  local s = test_screen_prepare()
  s:draw_line({y = 15, x = 15}, {y = 1, x = 1})
  Assert.is_false(s:compare('img/tests/test1.png'))
end

local function test_screen_tile_to_pixel()
  local y = 10
  local x = 5
  local screen = test_screen_prepare()
  local n = screen:tile_to_pixel({y = y, x = x})
  Assert.is_equal({y = (y - 1) * 25, x = (x - 1) * 25}, n)
end

local function test_screen()
  test_screen_line_1()
  test_screen_line_2()
  test_screen_line_3()
  test_screen_tile_to_pixel()
end

local function test_all()
  test_round()
  test_unittype_to_char()
  test_distance()
  test_clamp()
  test_misc_id_to_key()
  test_misc_neib()
  test_m2dir()
  test_int_to_char()
  test_screen()
  test_map()
  test_time_system()
  test_bresenham()
  test_misc_to_string()
  test_misc_dump()
  test_misc_compare()
  test_misc_copy()
  test_tr()
  test_priority_queue()
  -- test_pathfinder()
  print('All tests are Ok')
end

test_all()
