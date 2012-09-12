-- See LICENSE file for copyright and license details

local Misc = require 'misc'

local Pathfinder = {}
Pathfinder.__index = Pathfinder

Pathfinder.new = function()
  local self = {
    _map,
    _queue = {}
  }
  return setmetatable(self, Pathfinder)
end

Pathfinder.set_map = function(self, map)
  self._map = map
end

Pathfinder._reset_tiles_cost = function(self)
  assert(self._map)
  for y = 1, self._map:size().y do
    for x = 1, self._map:size().x do
      local pos = {y = y, x = x}
      self._map:tile(pos).cost = math.huge
    end
  end
end

Pathfinder._push_position = function(self, pos, parent_pos, cost)
  table.insert(self._queue, pos)
  self._map:tile(pos).cost = cost
  if parent_pos == nil then
    -- special value for start position
    self._map:tile(pos).parent = 0
  else
    self._map:tile(pos).parent = Misc.m2dir(pos, parent_pos)
  end
end

Pathfinder._process_neibor = function(self, pos, neib_pos)
  local t1 = self._map:tile(pos)
  local t2 = self._map:tile(neib_pos)
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
    self:_push_position(neib_pos, pos, cost)
  end
end

Pathfinder._try_to_push_neibors = function(self, pos)
  assert(self._map:is_inboard(pos))
  -- TODO: Get neiboorhoods list?
  for dir = 1, 8 do
    local neib_pos = Misc.neib(pos, dir)
    if self._map:is_inboard(neib_pos) then
      self:_process_neibor(pos, neib_pos)
    end
  end
end

Pathfinder._fill_map = function(self, from, to)
  assert(#self._queue == 0, Misc.to_string(self._queue))
  self:_reset_tiles_cost()
  self:_push_position(from, nil, 0) -- Push start position
  while #self._queue > 0 do
    local next_pos = table.remove(self._queue)
    if next_pos ~= nil then
      self:_try_to_push_neibors(next_pos)
    end
  end
end

Pathfinder.get_path = function(self, from, to)
  assert(self._map)
  assert(#self._queue == 0)
  self:_fill_map(from, to)
  assert(#self._queue == 0)
  local path = {}
  local pos = to
  while self._map:tile(pos).parent ~= 0 do
    table.insert(path, 1, pos)
    local dir = self._map:tile(pos).parent
    pos = Misc.neib(pos, dir)
  end
  table.insert(path, 1, from) -- Add start position
  return path
end

return Pathfinder
