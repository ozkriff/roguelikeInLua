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

  local process_neibor = function(pos, neib_pos)
    local t1 = map[pos.y][pos.x]
    local t2 = map[neib_pos.y][neib_pos.x]

    -- TODO: Mark somehow that unit stands in tile
    -- if self:unit_at(neib_pos) or not can_move_there(pos, neib_pos) then
    --   return
    -- end

    -- if t2.unit or t2.type == 'block' then -- TODO
    if t2.type == 'block' then
      return
    end

    -- local newcost = t1.cost + get_tile_cost(u, pos, neib_pos)

    -- local newcost = t1.cost + t2.cost
    local type_to_cost = {
      ['empty'] = 1,
      ['block'] = 999 -- TODO
    }
    local newcost = t1.cost + type_to_cost[t2.type]

    newcost = newcost + 1
    local dx = math.abs(neib_pos.x - pos.x)
    local dy = math.abs(neib_pos.y - pos.y)
    if dx ~= 0 then newcost = newcost + 1 end
    if dy ~= 0 then newcost = newcost + 1 end

    -- TODO what action points?! remove them
    -- local action_points = get_unit_type(u->type_id)->action_points
    -- if t2.cost > newcost and newcost <= action_points then
    -- print('process_neibor(): cost = '
    --     .. t2.cost .. ', newcost = ' .. newcost)

    if t2.cost > newcost then
      -- print('inserting')
      table.insert(queue, neib_pos)
      map[neib_pos.y][neib_pos.x].cost = newcost
      map[neib_pos.y][neib_pos.x].parent = Misc.m2dir(neib_pos, pos)
    end
  end

  local try_to_push_neibors = function(pos)
    -- print('try_to_push_neibors(): x = '.. pos.x .. ' y = ' .. pos.y)
    assert(map.inboard(pos))
    for dir = 1, 8 do
      local neib_pos = Misc.neib(pos, dir)
      -- TODO: Encapsulate it?
      if map.inboard(neib_pos) then
        process_neibor(pos, neib_pos)
      end
    end
  end

  local fill_map = function(from, to)
    -- print('fill_map()')
    assert(#queue == 0, Misc.to_string(queue)) -- TODO
    reset_tiles_cost()

    -- Push start position
    table.insert(queue, from)
    map[from.y][from.x].cost = 0
    map[from.y][from.x].parent = 0 -- special value

    while #queue > 0 do
      local next_pos = table.remove(queue)
      -- TODO: Get neiboorhoods list?
      -- print('fill_map(): iteration: <<<'
      --     .. Misc.to_string(next_pos) .. '>>>')
      if next_pos ~= nil then
        try_to_push_neibors(next_pos)
      end
    end
  end

  local print_map_debug_info = function()
    print('Map: cost:')
    for y = 1, map.size().y do
      for x = 1, map.size().x do
        local s = tostring(map[y][x].cost)
        while #s < 2 do s = ' ' .. s end
        io.write(s, ' ')
      end
      io.write('\n')
    end
    print('')
    -- print('Map: cost:')
    -- for y = 1, map.size().y do
    --   for x = 1, map.size().x do
    --     local s = tostring(map[y][x].cost)
    --     while #s < 2 do s = ' ' .. s end
    --     io.write(s, ' ')
    --   end
    --   io.write('\n')
    -- end
    print('')
    print('Map: parent:')
    for y = 1, map.size().y do
      for x = 1, map.size().x do
        local s = tostring(map[y][x].parent)
        while #s < 2 do s = ' ' .. s end
        io.write(s, ' ')
      end
      io.write('\n')
    end
  end

  self.get_path = function(from, to)
    assert(map)
    assert(#queue == 0)
    fill_map(from, to)
    -- print_map_debug_info()
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
