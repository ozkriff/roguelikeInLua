local Assert = require 'assert'
local Pathfinder = require 'pathfinder'

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

return function()
  test_pathfinder()
end
