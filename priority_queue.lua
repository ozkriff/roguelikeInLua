-- See LICENSE file for copyright and license details

-- A simple priority queue implementation

local PriorityQueue = {}
PriorityQueue.__index = PriorityQueue

PriorityQueue.new = function()
  local self = {
    _heap = {},
    _nodes = {}
  }
  return setmetatable(self, PriorityQueue)
end

PriorityQueue.push = function(self, k, v)
  assert(v ~= nil, "cannot push nil")
  local n = #self._heap + 1 -- node position in heap array (leaf)
  local p = (n - n % 2) / 2 -- parent position in heap array
  self._heap[n] = k -- insert at a leaf
  self._nodes[k] = v
  while n > 1 and self._nodes[self._heap[p]] < v do -- climb heap?
    self._heap[p], self._heap[n] = self._heap[n], self._heap[p]
    n = p
    p = (n - n % 2) / 2
  end
end

PriorityQueue.pop = function(self)
  local s = #self._heap
  assert(s > 0, "cannot pop from empty heap")
  local e = self._heap[1] -- min (heap root)
  local r = self._nodes[e]
  local v = self._nodes[self._heap[s]]
  self._heap[1] = self._heap[s] -- move leaf to root
  self._heap[s] = nil -- remove leaf
  self._nodes[e] = nil
  s = s - 1
  local n = 1 -- node position in heap array
  local p = 2 * n -- left sibling position
  if s > p and self._nodes[self._heap[p]] < self._nodes[self._heap[p + 1]] then
    p = 2 * n + 1 -- right sibling position
  end
  while s >= p and self._nodes[self._heap[p]] > v do -- descend heap?
    self._heap[p], self._heap[n] = self._heap[n], self._heap[p]
    n = p
    p = 2 * n
    if s > p and self._nodes[self._heap[p]] < self._nodes[self._heap[p + 1]] then
      p = 2 * n + 1
    end
  end
  return e, r
end

PriorityQueue.is_empty = function(self)
  return self._heap[1] == nil
end

return PriorityQueue
