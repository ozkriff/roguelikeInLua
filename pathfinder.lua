-- See LICENSE file for copyright and license details

local Misc = require 'misc'

local Pathfinder = {}
Pathfinder.__index = Pathfinder

function Pathfinder.new(map)
  assert(map)
  local new_pathfinder = {
    queue = {},
    map = map
  }
  return setmetatable(new_pathfinder, Pathfinder)
end

function Pathfinder:reset_tiles_cost()
  assert(self.map)
  for y = 1, self.map.size().y do
    for x = 1, self.map.size().x do
      self.map[y][x].current_cost = math.huge
    end
  end
end

function Pathfinder:inboard(pos)
  assert(pos)
  local size = self.map.size()
  if pos.y < 1 then
    return false
  end
  if pos.x < 1 then
    return false
  end
  if pos.y > size.y then
    return false
  end
  if pos.x > size.x then
    return false
  end
  return true
end

function Pathfinder:process_neibor(pos, neib_pos)
  local t1 = self.map[pos.y][pos.x]
  local t2 = self.map[neib_pos.y][neib_pos.x]

  -- TODO: Mark somehow that unit stands in tile
  -- if self:unit_at(neib_pos) or not can_move_there(pos, neib_pos) then
  --   return
  -- end

  -- if t2.unit or t2.type == 'block' then -- TODO
  if t2.type == 'block' then
    return
  end

  -- local newcost = t1.current_cost + get_tile_cost(u, pos, neib_pos)

  -- local newcost = t1.current_cost + t2.cost
  local name_me = {
    ['empty'] = 1,
    ['block'] = 999 -- TODO
  }
  local newcost = t1.current_cost
      + name_me[t2.type]

  newcost = newcost + 1
  local dx = math.abs(neib_pos.x - pos.x)
  local dy = math.abs(neib_pos.y - pos.y)
  if dx ~= 0 then newcost = newcost + 1 end
  if dy ~= 0 then newcost = newcost + 1 end

  -- TODO what action points?! remove them
  -- local action_points = get_unit_type(u->type_id)->action_points
  -- if t2.current_cost > newcost and newcost <= action_points then
  -- print('process_neibor(): current_cost = '
  --     .. t2.current_cost .. ', newcost = ' .. newcost)

  if t2.current_cost > newcost then
    -- print('inserting')
    table.insert(self.queue, neib_pos)
    self.map[neib_pos.y][neib_pos.x].current_cost = newcost
    self.map[neib_pos.y][neib_pos.x].parent = Misc.m2dir(pos, neib_pos)
  end
end

function Pathfinder:try_to_push_neibors(pos)
  -- print('try_to_push_neibors(): x = '.. pos.x .. ' y = ' .. pos.y)
  assert(self:inboard(pos))
  for dir = 1, 8 do
    local neib_pos = Misc.neib(pos, dir)
    -- TODO: Encapsulate it?
    if self:inboard(neib_pos) then
      self:process_neibor(pos, neib_pos)
    end
  end
end

function Pathfinder:fill_map(from, to)
  -- print('fill_map()')
  assert(#self.queue == 0, Misc.to_string(self.queue)) -- TODO
  self:reset_tiles_cost()

  -- Push start position
  table.insert(self.queue, from)
  self.map[from.y][from.x].current_cost = 0
  self.map[from.y][from.x].parent = 0 -- special value

  while #self.queue > 0 do
    local next_pos = table.remove(self.queue)
    -- TODO: Get neiboorhoods list?
    -- print('fill_map(): iteration: <<<'
    --     .. Misc.to_string(next_pos) .. '>>>')
    if next_pos ~= nil then
      self:try_to_push_neibors(next_pos)
    end
  end
end

function Pathfinder:print_map_debug_info()
  print('Map: current_cost:')
  for y = 1, self.map.size().y do
    for x = 1, self.map.size().x do
      local s = tostring(self.map[y][x].current_cost)
      while #s < 2 do s = ' ' .. s end
      io.write(s, ' ')
    end
    io.write('\n')
  end
  print('')
  -- print('Map: cost:')
  -- for y = 1, self.map.size().y do
  --   for x = 1, self.map.size().x do
  --     local s = tostring(self.map[y][x].cost)
  --     while #s < 2 do s = ' ' .. s end
  --     io.write(s, ' ')
  --   end
  --   io.write('\n')
  -- end
  print('')
  print('Map: parent:')
  for y = 1, self.map.size().y do
    for x = 1, self.map.size().x do
      local s = tostring(self.map[y][x].parent)
      while #s < 2 do s = ' ' .. s end
      io.write(s, ' ')
    end
    io.write('\n')
  end
end

function Pathfinder:get_path(from, to)
  assert(self.map)
  assert(#self.queue == 0)
  self:fill_map(from, to)
  -- self:print_map_debug_info()
  assert(#self.queue == 0)
  local path = {}
  local pos = to
  while self.map[pos.y][pos.x].parent ~= 0 do
    table.insert(path, 1, pos)
    local dir = self.map[pos.y][pos.x].parent
    pos = Misc.neib(pos, dir)
  end
  table.insert(path, 1, from) -- Add start position
  return path
end

return Pathfinder
