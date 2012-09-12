-- See LICENSE file for copyright and license details

local Misc = require 'misc'
local Enemy = require 'enemy'
local Player = require 'player'
local Symbols = require 'symbols'
local Bresenham = require 'bresenham'

local Game = {}
Game.__index = Game

Game.new = function()
  local self = {
    _max_see_distance = 99,
    _units = {},
    _is_running = true,
    _player = 0,
    _action_cost = {
      fire = 80,
      move = 40,
      wait = 20
    },
    _screen,
    _map,
    _pathfinder,
    _log,
    _time_system,
    target_position -- TODO: setter/getter?
  }
  return setmetatable(self, Game)
end

Game.max_see_distance = function(self)
  return self._max_see_distance
end

Game.set_is_running = function(self, is_running)
  self._is_running = is_running
end

Game.units = function(self)
  return self._units
end

Game.player = function(self)
  return self._player
end

Game.action_cost = function(self)
  return self._action_cost
end

Game.set_screen = function(self, screen)
  self._screen = screen
end

Game.screen = function(self)
  return self._screen
end

Game.set_map = function(self, map)
  self._map = map
end

Game.map = function(self)
  return self._map
end

Game.set_pathfinder = function(self, pathfinder)
  self._pathfinder = pathfinder
end

Game.pathfinder = function(self)
  return self._pathfinder
end

Game.set_log = function(self, log)
  self._log = log
end

Game.log = function(self)
  return self._log
end

Game.set_time_system = function(self, time_system)
  self._time_system = time_system
end

Game.time_system = function(self)
  return self._time_system
end

Game.unit_type_to_char = function(type)
  local table = {
    ['player'] = Symbols.AT,
    ['enemy'] = Symbols.Z,
  }
  return table[type]
end

Game._draw_units = function(self)
  for key, unit in pairs(self._units) do
    -- TODO
    -- self.screen:move(
    --     self.map.pos.y + unit.pos.y,
    --     self.map.pos.x + unit.pos.x)
    self._screen:move(unit:pos())
    if Bresenham.los(self._player:pos(), unit:pos(),
        function(pos)
          return self._map:tile(pos).type == 'empty'
        end)
    then
      self._screen:draw_symbol(self.unit_type_to_char(unit:type()))
      self._screen:move(unit:pos())
      self._screen:draw_symbol(Symbols.ARROW_UP)
    else
      self._screen:draw_symbol(Symbols.Q)
    end
  end
end

-- TODO test
local function create_fov_callback(y, x, map)
  return function(pos)
    -- last tile in line must be visible
    if pos.x == x and pos.y == y then
      return true
    else
      return map:tile(pos).type == 'empty'
    end
  end
end

-- TODO test
Game.update_fov = function(self)
  for y = 1, self._map:size().y do
    for x = 1, self._map:size().x do
      local pos = {y = y, x = x}
      self._map:tile(pos).is_seen = Bresenham.los(
          self._player:pos(), pos,
          create_fov_callback(y, x, self._map)
      )
    end
  end
end

Game._draw_line_of_fire = function(self)
  if not self.target_position then
    return
  end
  local a = self._screen:tile_to_pixel(self._player:pos())
  local b = self._screen:tile_to_pixel(self.target_position)
  a.x = a.x + 25 / 2
  a.y = a.y + 25 / 2
  b.x = b.x + 25 / 2
  b.y = b.y + 25 / 2
  self._screen:draw_line(a, b)
end

Game.draw = function(self)
  self._screen:clear()
  self._map:draw()
  self._log:draw()
  self:_draw_units()
  self._screen:draw_line({y = 400, x = 100}, {y = 420, x = 140})
  self._screen:draw_line({y = 420, x = 140}, {y = 420, x = 200})
  self:_draw_line_of_fire()
  self._screen:refresh()
end

Game.is_position_free = function(self, pos)
  if not self._map:is_tile_free(pos) then
    return false
  end
  for key, unit in pairs(self._units) do
    if Misc.compare(unit:pos(), pos) then
      return false
    end
  end
  return true
end

Game.kill_unit = function(self, unit_id)
  self._log:add('killed ' .. unit_id)
  self._time_system:remove_actor(unit_id)
  local key = Misc.id_to_key(self._units, unit_id)
  local unit = self._units[key]
  self._map:tile(unit:pos()).unit = false
  table.remove(self._units, key)
end

Game.get_next_command = function(self)
  return Misc.int_to_char(self._screen:get_char())
end

Game._add_unit = function(self, unit)
  table.insert(self._units, unit)
  unit.id = #self._units
  unit.game = self -- TODO
  self._time_system:add_actor(unit, unit.id)
  self._map:tile(unit:pos()).unit = true
end

Game._add_unit_ai = function(self, pos)
  local unit = Enemy.new(self)
  unit:set_pos(pos)
  self:_add_unit(unit)
end

Game._add_unit_player = function(self, pos)
  local unit = Player.new(self)
  unit:set_pos(pos)
  self:_add_unit(unit)
  self._player = unit
end

Game._get_free_pos = function(self)
  local pos
  repeat
    pos = self._map:get_random_pos()
    local t = self._map:tile(pos)
  until t.type == 'empty' and not t.unit
  return pos
end

Game._create_units = function(self)
  -- local units_count = 10 -- TODO
  local units_count = 3
  for i = 1, units_count do
    self:_add_unit_ai(self:_get_free_pos())
  end
  self:_add_unit_player(self:_get_free_pos())
end

Game.unit_at = function(self, pos)
  for key, unit in pairs(self._units) do
    if Misc.compare(unit:pos(), pos) then
      return unit
    end
  end
  return nil
end

-- TODO joint and test this
Game._add_random_vertical_wall = function(self)
  local pos = self._map:get_random_pos()
  local length = math.random(1, 10)
  for i = 0, length do
    if pos.y + i <= self._map:size().y then
      self._map:tile({y = pos.y + i, x = pos.x}).type = 'block'
    end
  end
end

Game._add_random_horizontal_wall = function(self)
  local pos = self._map:get_random_pos()
  local length = math.random(1, 10)
  for i = 0, length do
    if pos.x + i <= self._map:size().x then
      self._map:tile({y = pos.y, x = pos.x + i}).type = 'block'
    end
  end
end

Game._init_test_obstacles = function(self)
  for i = 1, 4 do
    self:_add_random_vertical_wall()
    self:_add_random_horizontal_wall()
  end
end

Game.init = function(self)
  assert(self._map)
  assert(self._pathfinder)
  assert(self._log)
  assert(self._time_system)
  assert(self._screen)
  self:_init_test_obstacles()
  self:_create_units()
  self:update_fov()
  self._screen:init({y = 480, x = 640}, 32)
  -- self._log:add('initialized')
end

Game.close = function(self)
  self._screen:close()
end

Game.mainloop = function(self)
  while self._is_running do
    self._time_system:step()
  end
end

return Game
