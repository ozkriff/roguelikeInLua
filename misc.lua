-- See LICENSE file for copyright and license details

local Misc = {}

-- from http://lua-users.org/wiki/SimpleRound
function Misc.round(num, idp)
  local mult = 10 ^ (idp or 0)
  if num >= 0 then
    return math.floor(num * mult + 0.5) / mult
  else
    return math.ceil(num * mult - 0.5) / mult
  end
end

function Misc.distance(from, to)
  local dx = math.abs(to.x - from.x)
  local dy = math.abs(to.y - from.y)
  local n = math.sqrt(dx * dx + dy * dy)
  local n = math.sqrt(dx ^ 2 + dy ^ 2)
  return Misc.round(n)
end

function Misc.int_to_char(n)
  return string.char(n)
end

local function table_print(tt, indent, done)
  done = done or {}
  indent = indent or 0
  if type(tt) == 'table' then
    local sb = {}
    for key, value in pairs(tt) do
      table.insert(sb, string.rep(' ', indent)) -- indent it
      if type (value) == 'table' and not done [value] then
        done [value] = true
        table.insert(sb, '{\n');
        table.insert(sb, table_print(value, indent + 2, done))
        table.insert(sb, string.rep(' ', indent)) -- indent it
        table.insert(sb, '}\n');
      elseif 'number' == type(key) then
        table.insert(sb, string.format('\'%s\'\n', tostring(value)))
      else
        table.insert(sb, string.format(
            '%s = \'%s\'\n', tostring (key), tostring(value)))
       end
    end
    return table.concat(sb)
  else
    return tt .. '\n'
  end
end

-- TODO: test!
function Misc.to_string(table)
  if type(table) == 'nil' then
    return tostring(nil)
  elseif type(table) == 'table' then
    return table_print(table)
  elseif type(table) == 'string' then
    return table
  else
    return tostring(table)
  end
end

-- TODO: test!
function Misc.id_to_key(table, id)
  assert(table)
  assert(id)
  for k, v in pairs(table) do
    assert(v.id)
    if v.id == id then
      return k, v
    end
  end
  return nil
end

-- This function recursively copies a table's contents,
-- and ensures that metatables are preserved.
-- That is, it will correctly clone a pure Lua object.
function Misc.deepcopy(t)
  if type(t) ~= 'table' then
    return t
  end
  local mt = getmetatable(t)
  local res = {}
  for k, v in pairs(t) do
    if type(v) == 'table' then
      v = deepcopy(v)
    end
    res[k] = v
  end
  return setmetatable(res, mt)
end

-- This will compare two Lua values, and recursively
-- compare the values of any tables encountered.
-- By default, it will respect metamethods - that is,
-- if two objects of the same type support __eq this
-- will be used. If the third parameter is true then
-- metatables are ignored in the comparison.
--
-- For instance, say we have a List class, then
--   assert(deepcompare(List{1, 2, 3}, {1, 2, 3}, true))
function Misc.deepcompare(t1, t2, ignore_mt)
  local ty1 = type(t1)
  local ty2 = type(t2)
  if ty1 ~= ty2 then return false end
  -- non-table types can be directly compared
  if ty1 ~= 'table' and ty2 ~= 'table' then
    return t1 == t2
  end
  -- as well as tables which have the metamethod __eq
  local mt = getmetatable(t1)
  if not ignore_mt and mt and mt.__eq then
    return t1 == t2
  end
  for k1, v1 in pairs(t1) do
    local v2 = t2[k1]
    if v2 == nil or not Misc.deepcompare(v1, v2) then
      return false
    end
  end
  for k2, v2 in pairs(t2) do
    local v1 = t1[k2]
    if v1 == nil or not Misc.deepcompare(v1, v2) then
      return false
    end
  end
  return true
end

-- This creates a string representation of a table,
-- in a form like {[1]=10, [2]=20, ["name"]="alice"}.
-- Not very efficient, because of all the string
-- concatentations, and will freak if given a table
-- with cycles, i.e. with recursive references.
function Misc.dump(o)
  if type(o) == 'table' then
    local s = '{ '
    for k, v in pairs(o) do
      if type(k) ~= 'number' then k = '\''..k..'\'' end
      s = s .. '['..k..'] = ' .. Misc.dump(v) .. ', '
    end
    return s .. '} '
  else
    return tostring(o)
  end
end

local dir_to_pos_diff = {
  {y = -1, x = 0},
  {y = -1, x = 1},
  {y = 0, x = 1},
  {y = 1, x = 1},
  {y = 1, x = 0},
  {y = 1, x = -1},
  {y = 0, x = -1},
  {y = -1, x = -1},
}

-- TODO test rename
-- Get tile's neiborhood by it's index.
function Misc.neib(pos, neib_index)
  assert(neib_index >= 1 and neib_index <= 8)
  local dx = dir_to_pos_diff[neib_index].x
  local dy = dir_to_pos_diff[neib_index].y
  return {y = pos.y + dy, x = pos.x + dx}
end

-- TODO test rename
function Misc.m2dir(a, b)
  if Misc.distance(a, b) ~= 1 then
    return nil
  end
  local d = {y = b.y - a.y, x = b.x - a.x}
  for i = 1, 8 do
    if Misc.deepcompare(d, dir_to_pos_diff[i]) then
      return i
    end
  end
  return nil
end

return Misc
