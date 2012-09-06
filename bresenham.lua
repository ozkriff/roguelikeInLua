-- See LICENSE file for copyright and license details

local Bresenham = {}

function Bresenham.los(x1, y1, x2, y2, callback)
  local sx, sy, dx, dy
  if x1 < x2 then
    sx = 1
    dx = x2 - x1
  else
    sx = -1
    dx = x1 - x2
  end
  if y1 < y2 then
    sy = 1
    dy = y2 - y1
  else
    sy = -1
    dy = y1 - y2
  end
  local err = dx - dy
  local e2 = nil
  if not callback(x1, y1) then
    return false
  end
  while not (x1 == x2 and y1 == y2) do
    e2 = err + err
    if e2 > -dy then
      err = err - dy
      x1  = x1 + sx
    end
    if e2 < dx then
      err = err + dx
      y1  = y1 + sy
    end
    if not callback(x1, y1) then
      return false
    end
  end
  return true
end

function Bresenham.line(x1, y1, x2, y2, callback)
  local points = {}
  local count = 0
  local result = Bresenham.los(x1, y1, x2, y2, function(x, y)
    if callback and not callback(x, y) then
      return false
    end
    count = count + 1
    points[count] = {x = x, y = y}
    return true
  end)
  return points, result
end

return Bresenham
