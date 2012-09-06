-- See LICENSE file for copyright and license details

local Misc = require 'misc'

local Bresenham = {}

function Bresenham.los(from, to, callback)
  local sign = {}
  local diff = {}
  local pos = Misc.copy(from)
  if pos.x < to.x then
    sign.x = 1
    diff.x = to.x - pos.x
  else
    sign.x = -1
    diff.x = pos.x - to.x
  end
  if pos.y < to.y then
    sign.y = 1
    diff.y = to.y - pos.y
  else
    sign.y = -1
    diff.y = pos.y - to.y
  end
  local err = diff.x - diff.y
  local e2 = nil
  if not callback(pos) then
    return false
  end
  while not Misc.compare(pos, to) do
    e2 = err + err
    if e2 > -diff.y then
      err = err - diff.y
      pos.x  = pos.x + sign.x
    end
    if e2 < diff.x then
      err = err + diff.x
      pos.y  = pos.y + sign.y
    end
    if not callback(pos) then
      return false
    end
  end
  return true
end

function Bresenham.line(from, to, callback)
  local points = {}
  local count = 0
  local result = Bresenham.los(from, to, function(pos)
    if callback and not callback(pos) then
      return false
    end
    count = count + 1
    points[count] = Misc.copy(pos)
    return true
  end)
  return points, result
end

return Bresenham
