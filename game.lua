-- See LICENSE file for copyright and license details

local Misc = require 'misc'
local Enemy = require 'enemy'
local Player = require 'player'
local Symbols = require 'symbols'
local Bresenham = require 'bresenham'

return function()
  local self = {}

  local max_see_distance = 10
  local units = {}
  local is_running = true
  local player = 0
  local action_cost = {
    fire = 80,
    move = 40,
    wait = 20
  }
  local screen
  local map
  local pathfinder
  local log
  local time_system

  self.max_see_distance = function()
    return max_see_distance
  end

  self.set_is_running = function(new_is_running)
    is_running = new_is_running
  end

  self.units = function()
    return units
  end

  self.player = function()
    return player
  end

  self.action_cost = function()
    return action_cost
  end

  self.set_screen = function(new_screen)
    screen = new_screen
  end

  self.screen = function()
    return screen
  end

  self.set_map = function(new_map)
    map = new_map
  end

  self.map = function()
    return map
  end

  self.set_pathfinder = function(new_pathfinder)
    pathfinder = new_pathfinder
  end

  self.pathfinder = function()
    return pathfinder
  end

  self.set_log = function(new_log)
    log = new_log
  end

  self.log = function()
    return log
  end

  self.set_time_system = function(new_time_system)
    time_system = new_time_system
  end

  self.time_system = function()
    return time_system
  end

  self.unit_type_to_char = function(type)
    local table = {
      ['player'] = Symbols.AT,
      ['enemy'] = Symbols.Z,
    }
    return table[type]
  end

  local draw_units = function()
    for key, unit in pairs(units) do
      -- TODO
      -- self.screen:move(
      --     self.map.pos.y + unit.pos.y,
      --     self.map.pos.x + unit.pos.x)
      screen:move(unit.pos().y, unit.pos().x)
      if Bresenham.los(player.pos(), unit.pos(),
          function(pos)
            return map[pos.y][pos.x].type == 'empty'
          end)
      then
        screen:printf(self.unit_type_to_char(unit.type()))
        screen:move(unit.pos().y, unit.pos().x)
        screen:printf(Symbols.ARROW_UP)
      else
        screen:printf(Symbols.Q)
      end
    end
  end

  -- TODO test
  self.update_fov = function()
    for y = 1, map.size().y do
      for x = 1, map.size().x do
        map[y][x].is_seen = Bresenham.los(
            player.pos(), {y = y, x = x},
            function(pos)
              -- last tile in line must be visible
              if pos.x == x and pos.y == y then
                return true
              else
                return map[pos.y][pos.x].type == 'empty'
              end
            end
        )
      end
    end
  end

  self.draw = function()
    screen:clear()
    map.draw()
    log.draw()
    draw_units()
    screen:line(400, 100, 420, 140)
    screen:line(420, 140, 420, 200)
    screen:refresh()
  end

  self.is_position_free = function(pos)
    if not map.is_tile_free(pos) then
      return false
    end
    for key, unit in pairs(units) do
      if unit.pos().x == pos.x
          and unit.pos().y == pos.y
      then
        return false
      end
    end
    return true
  end

  self.kill_unit = function(unit_id)
    log.add('killed ' .. unit_id)
    time_system.remove_actor(unit_id)
    local key = Misc.id_to_key(units, unit_id)
    table.remove(units, key)
  end

  self.get_next_command = function()
    -- print 'Game:get_next_command()'
    return Misc.int_to_char(screen:get_char())
  end

  local add_unit = function(unit)
    table.insert(units, unit)
    -- unit.id = #self.units + 1
    unit.id = #units
    unit.game = self -- TODO
    time_system.add_actor(unit, unit.id)
    map[unit.pos().y][unit.pos().x].unit = true
  end

  local add_unit_ai = function(pos)
    unit = Enemy(self)
    unit.set_pos(pos)
    add_unit(unit)
  end

  local add_unit_player = function(pos)
    unit = Player(self)
    unit.set_pos(pos)
    add_unit(unit)
    player = unit
  end

  local create_units = function()
    -- local units_count = 10 -- TODO
    local units_count = 3
    for i = 1, units_count do
      add_unit_ai(map.get_random_pos())
    end
    add_unit_player(map.get_random_pos())
  end

  self.unit_at = function(pos)
    for key, unit in pairs(units) do
      -- TODO Vector2:is_equal()
      if unit.pos().y == pos.y
          and unit.pos().x == pos.x
      then
        return unit
      end
    end
    return nil
  end

  -- TODO joint and test this
  local add_random_vertical_wall = function()
    local pos = map.get_random_pos()
    local length = math.random(1, 10)
    for i = 0, length do
      if pos.y + i <= map.size().y then
        map[pos.y + i][pos.x].type = 'block'
      end
    end
  end

  local add_random_horizontal_wall = function()
    local pos = map.get_random_pos()
    local length = math.random(1, 10)
    for i = 0, length do
      if pos.x + i <= map.size().x then
        map[pos.y][pos.x + i].type = 'block'
      end
    end
  end

  local init_test_obstacles = function()
    for i = 1, 4 do
      add_random_vertical_wall()
      add_random_horizontal_wall()
    end
  end

  self.init = function()
    assert(map)
    assert(pathfinder)
    assert(log)
    assert(time_system)
    assert(screen)
    init_test_obstacles()
    create_units()
    self.update_fov()
    screen:init(480, 640, 32)
    -- self.log.add('initialized')
  end

  self.close = function()
    screen:close()
  end

  self.mainloop = function()
    while is_running do
      time_system.step()
    end
  end

  return self
end
