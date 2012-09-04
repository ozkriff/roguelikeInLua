-- See LICENSE file for copyright and license details
-- A simple priority queue implementation
--   for i=1,10 do q:push(i, math.random()) end
--   while not q:is_empty() do print(q:pop()) end
-- Note that keys can be arbitrary:
--   for i=1,10 do
--     q:push(math.random() > 0.5 and newproxy() or {}, math.random())
--   end
--   while not q:is_empty() do print(q:pop()) end

local PriorityQueue = {}
PriorityQueue.__index = PriorityQueue

function PriorityQueue:push(k, v)
  assert(v ~= nil, "cannot push nil")
  local t = self.nodes
  local self = self.heap
  local n = #self + 1 -- node position in heap array (leaf)
  local p = (n - n % 2) / 2 -- parent position in heap array
  self[n] = k -- insert at a leaf
  t[k] = v
  while n > 1 and t[self[p]] < v do -- climb heap?
    self[p], self[n] = self[n], self[p]
    n = p
    p = (n - n % 2) / 2
  end
end

function PriorityQueue:pop()
  local t = self.nodes
  local self = self.heap
  local s = #self
  assert(s > 0, "cannot pop from empty heap")
  local e = self[1] -- min (heap root)
  local r = t[e]
  local v = t[self[s]]
  self[1] = self[s] -- move leaf to root
  self[s] = nil -- remove leaf
  t[e] = nil
  s = s - 1
  local n = 1 -- node position in heap array
  local p = 2 * n -- left sibling position
  if s > p and t[self[p]] < t[self[p + 1]] then
    p = 2 * n + 1 -- right sibling position
  end
  while s >= p and t[self[p]] > v do -- descend heap?
    self[p], self[n] = self[n], self[p]
    n = p
    p = 2 * n
    if s > p and t[self[p]] < t[self[p + 1]] then
      p = 2 * n + 1
    end
  end
  return e, r
end

function PriorityQueue:is_empty()
  return self.heap[1] == nil
end

function PriorityQueue.new()
  local new_queue = {
    heap = {},
    nodes = {}
  }
  return setmetatable(new_queue, PriorityQueue)
end

return PriorityQueue
