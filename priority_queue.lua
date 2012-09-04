-- See LICENSE file for copyright and license details
-- A simple priority queue implementation
--   for i=1,10 do q:push(i, math.random()) end
--   while not q:is_empty() do print(q:pop()) end
-- Note that keys can be arbitrary:
--   for i=1,10 do
--     q:push(math.random() > 0.5 and newproxy() or {}, math.random())
--   end
--   while not q:is_empty() do print(q:pop()) end

return function()
  local self = {}

  local heap = {}
  local nodes = {}

  self.push = function(k, v)
    assert(v ~= nil, "cannot push nil")
    local n = #heap + 1 -- node position in heap array (leaf)
    local p = (n - n % 2) / 2 -- parent position in heap array
    heap[n] = k -- insert at a leaf
    nodes[k] = v
    while n > 1 and nodes[heap[p]] < v do -- climb heap?
      heap[p], heap[n] = heap[n], heap[p]
      n = p
      p = (n - n % 2) / 2
    end
  end

  self.pop = function()
    local s = #heap
    assert(s > 0, "cannot pop from empty heap")
    local e = heap[1] -- min (heap root)
    local r = nodes[e]
    local v = nodes[heap[s]]
    heap[1] = heap[s] -- move leaf to root
    heap[s] = nil -- remove leaf
    nodes[e] = nil
    s = s - 1
    local n = 1 -- node position in heap array
    local p = 2 * n -- left sibling position
    if s > p and nodes[heap[p]] < nodes[heap[p + 1]] then
      p = 2 * n + 1 -- right sibling position
    end
    while s >= p and nodes[heap[p]] > v do -- descend heap?
      heap[p], heap[n] = heap[n], heap[p]
      n = p
      p = 2 * n
      if s > p and nodes[heap[p]] < nodes[heap[p + 1]] then
        p = 2 * n + 1
      end
    end
    return e, r
  end

  self.is_empty = function()
    return heap[1] == nil
  end

  return self
end
