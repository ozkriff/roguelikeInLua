-- See LICENSE file for copyright and license details

local Log = require 'log'
local Map = require 'map'
local TimeSystem = require 'time_system'
local Game = require 'game'
local Misc = require 'misc'
local Bresenham = require 'bresenham'
local Pathfinder = require 'pathfinder'
local Symbols = require 'symbols'
local Assert = require 'assert'

local TestAll = {}
TestAll.__index = TestAll

local function test_unittype_to_char()
  Assert.is_equal(Game.unit_type_to_char('player'), Symbols.AT)
  Assert.is_equal(Game.unit_type_to_char('enemy'), Symbols.Z)
  Assert.is_nil(Game.unit_type_to_char('ololo'))
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
  -- TODO: How? Create mock units?
end

-- TODO: Rewrite
local function test_main()
  math.randomseed(os.time())
  local screen = TestScreen.new()
  screen:set_pressed_keys {
    'h', 'h', 'h',
    -- 'f', 'g', 'f', -- TODO
    'h', 'h', 'h', 'h',
    -- 'f', 'g', 'f', -- TODO
    'h', 'h', 'h',
    'q'
  }
  local map = Map.new {
    size = {y = 20, x = 60},
    pos = {y = 2, x = 3},
    screen = screen
  }
  local log = Log.new {
    pos = {y = 20, x = 1},
    max_size = 4,
    screen = screen
  }
  local time_system = TimeSystem.new()
  local game = Game.new {
    screen = screen,
    map = map,
    log = log,
    time_system = time_system
  }
  game:init()
  game:mainloop()
  game:close()
end

local function test_bresenham()
  Assert.is_equal(Bresenham.line(1, 1, 1, 1), {{1, 1}})
  Assert.is_equal(Bresenham.line(1, 1, 2, 2), {{1, 1}, {2, 2}})
  Assert.is_equal(Bresenham.line(3, 3, 2, 2), {{3, 3}, {2, 2}})
  Assert.is_equal(Bresenham.line(1, 1, 3, 5),
      {{1, 1}, {1, 2}, {2, 3}, {2, 4}, {3, 5}})
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


local function test_misc_neib()
  local a = {y = 2, x = 2}
  local up = {y = 1, x = 2}
  local up_right = {y = 1, x = 3}
  local right = {y = 2, x = 3}
  local down_right = {y = 3, x = 3}
  local down = {y = 3, x = 2}
  local down_left = {y = 3, x = 1}
  local left = {y = 2, x = 1}
  local up_left = {y = 1, x = 1}
  Assert.is_equal(Misc.neib(a, 1), up)
  Assert.is_equal(Misc.neib(a, 2), up_right)
  Assert.is_equal(Misc.neib(a, 3), right)
  Assert.is_equal(Misc.neib(a, 4), down_right)
  Assert.is_equal(Misc.neib(a, 5), down)
  Assert.is_equal(Misc.neib(a, 6), down_left)
  Assert.is_equal(Misc.neib(a, 7), left)
  Assert.is_equal(Misc.neib(a, 8), up_left)
end

local function test_m2dir()
  local a = {y = 2, x = 2}
  local up = {y = 1, x = 2}
  local up_right = {y = 1, x = 3}
  local right = {y = 2, x = 3}
  local down_right = {y = 3, x = 3}
  local down = {y = 3, x = 2}
  local down_left = {y = 3, x = 1}
  local left = {y = 2, x = 1}
  local up_left = {y = 1, x = 1}
  local distant_point = {y = 4, x = 4}
  Assert.is_equal(Misc.m2dir(a, up), 1)
  Assert.is_equal(Misc.m2dir(a, up_right), 2)
  Assert.is_equal(Misc.m2dir(a, right), 3)
  Assert.is_equal(Misc.m2dir(a, down_right), 4)
  Assert.is_equal(Misc.m2dir(a, down), 5)
  Assert.is_equal(Misc.m2dir(a, down_left), 6)
  Assert.is_equal(Misc.m2dir(a, left), 7)
  Assert.is_equal(Misc.m2dir(a, up_left), 8)
  Assert.is_nil(Misc.m2dir(a, distant_point))
  Assert.is_nil(Misc.m2dir(a, a))
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

function TestAll.test_all()
  test_round()
  test_unittype_to_char() -- TODO
  test_distance()
  test_misc_id_to_key()
  test_misc_neib()
  test_m2dir()
  test_int_to_char()
  -- test_screen()
  test_map()
  test_time_system()
  test_bresenham()
  test_misc_to_string()
  test_misc_dump()
  -- test_pathfinder()
  -- test_main() -- TODO fix
  print('All tests are Ok')
end

TestAll.test_all()
