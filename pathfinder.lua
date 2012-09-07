-- See LICENSE file for copyright and license details

local Misc = require 'misc'

return function(map)
  local self = {}

  assert(map)
  local map = map
  local queue = {}

  local reset_tiles_cost = function()
    assert(map)
    for y = 1, map.size().y do
      for x = 1, map.size().x do
        map[y][x].cost = math.huge
      end
    end
  end

  local push_position = function(pos, parent_pos, cost)
    table.insert(queue, pos)
    map[pos.y][pos.x].cost = cost
    if parent_pos == nil then
      -- special value for start position
      map[pos.y][pos.x].parent = 0
    else
      map[pos.y][pos.x].parent = Misc.m2dir(pos, parent_pos)
    end
  end

  local process_neibor = function(pos, neib_pos)
    local t1 = map[pos.y][pos.x]
    local t2 = map[neib_pos.y][neib_pos.x]
    if t2.unit or t2.type == 'block' then
      return
    end
    local type_to_cost = {
      ['empty'] = 1,
      ['block'] = 999 -- TODO
    }
    local cost = t1.cost + type_to_cost[t2.type] + 1
    if math.abs(neib_pos.x - pos.x) ~= 0 then
      cost = cost + 1
    end
    if math.abs(neib_pos.y - pos.y) ~= 0 then
      cost = cost + 1
    end
    if t2.cost > cost then
      push_position(neib_pos, pos, cost)
    end
  end

  local try_to_push_neibors = function(pos)
    assert(map.is_inboard(pos))
    for dir = 1, 8 do
      local neib_pos = Misc.neib(pos, dir)
      if map.is_inboard(neib_pos) then
        process_neibor(pos, neib_pos)
      end
    end
  end

  local fill_map = function(from, to)
    assert(#queue == 0, Misc.to_string(queue))
    reset_tiles_cost()
    push_position(from, nil, 0) -- Push start position
    while #queue > 0 do
      local next_pos = table.remove(queue)
      -- TODO: Get neiboorhoods list?
      if next_pos ~= nil then
        try_to_push_neibors(next_pos)
      end
    end
  end

  self.get_path = function(from, to)
    assert(map)
    assert(#queue == 0)
    fill_map(from, to)
    assert(#queue == 0)
    local path = {}
    local pos = to
    while map[pos.y][pos.x].parent ~= 0 do
      table.insert(path, 1, pos)
      local dir = map[pos.y][pos.x].parent
      pos = Misc.neib(pos, dir)
    end
    table.insert(path, 1, from) -- Add start position
    return path
  end

  return self
end
