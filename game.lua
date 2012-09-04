-- See LICENSE file for copyright and license details

local Misc = require 'misc'
local Enemy = require 'enemy'
local Player = require 'player'
local Symbols = require 'symbols'
local Bresenham = require 'bresenham'

local Game = {}
Game.__index = Game

function Game.new(screen, map, pathfinder, log, time_system)
  assert(map)
  assert(pathfinder)
  assert(log)
  assert(time_system)
  assert(screen)
  local new_game = {
    screen = screen,
    map = map,
    pathfinder = pathfinder,
    log = log,
    time_system = time_system,
    is_running = true,
    max_see_distance = 10,
    units = {},
    player = 0,
    action_cost = {
      fire = 80,
      move = 40,
      wait = 20
    }
  }
  return setmetatable(new_game, Game)
end

function Game.unit_type_to_char(type)
  local table = {
    ['player'] = Symbols.AT,
    ['enemy'] = Symbols.Z,
  }
  return table[type]
end

function Game:draw_units()
  for key, unit in pairs(self.units) do
    -- TODO
    -- self.screen:move(
    --     self.map.pos.y + unit.pos.y,
    --     self.map.pos.x + unit.pos.x)
    self.screen:move(unit.pos.y, unit.pos.x)
    if Bresenham.los(
        self.player.pos.x, self.player.pos.y,
        unit.pos.x, unit.pos.y,
        function(x, y)
          return self.map[y][x].type == 'empty'
        end)
    then
      self.screen:printf(self.unit_type_to_char(unit.type))
      self.screen:move(unit.pos.y, unit.pos.x)
      self.screen:printf(Symbols.ARROW_UP)
    else
      self.screen:printf(Symbols.Q)
    end
  end
end

-- TODO test
function Game:update_fov()
  for y = 1, self.map.size().y do
    for x = 1, self.map.size().x do
      self.map[y][x].is_seen = Bresenham.los(
          self.player.pos.x, self.player.pos.y, x, y,
          -- TODO x2? y2? ?! Rename args.
          function(x2, y2)
            -- last tile in line must be visible
            if x2 == x and y2 == y then
              return true
            else
              return self.map[y2][x2].type == 'empty'
            end
          end
      )
    end
  end
end

function Game:draw()
  self.screen:clear()
  self.map.draw()
  self.log.draw()
  self:draw_units()
  -- screen:move(map.size().y + 2, 0)
  -- self.screen:move(1, 1)
  self.screen:line(400, 100, 420, 140)
  self.screen:line(420, 140, 420, 200)
  -- self.screen:px_print(100, 100, 'test\ntest')
  -- self.screen:px_print(400, 50,
  --     'self.screen:line(100, 100, 200, 100)\n\z
  --      self.screen:px_print(200, 50, \n')
  -- self.screen:printf(Symbols.Q)
  self.screen:refresh()
end

function Game:is_position_free(pos)
  if not self.map.is_tile_free(pos) then
    return false
  end
  for key, unit in pairs(self.units) do
    if unit.pos.x == pos.x
        and unit.pos.y == pos.y
    then
      return false
    end
  end
  return true
end

function Game:get_next_command()
  -- print 'Game:get_next_command()'
  return Misc.int_to_char(self.screen:get_char())
end

function Game:add_unit(unit)
  table.insert(self.units, unit)
  -- unit.id = #self.units + 1
  unit.id = #self.units
  unit.game = self -- TODO
  self.time_system.add_actor(unit, unit.id)
  self.map[unit.pos.y][unit.pos.x].unit = true
end

function Game:add_unit_ai(pos)
  unit = Enemy.new()
  unit.pos = pos
  self:add_unit(unit)
end

function Game:add_unit_player(pos)
  unit = Player.new()
  unit.pos = pos
  self:add_unit(unit)
  self.player = unit
end

function Game:create_units()
  -- local units_count = 10 -- TODO
  local units_count = 3
  for i = 1, units_count do
    self:add_unit_ai(self.map.get_random_pos())
  end
  self:add_unit_player(self.map.get_random_pos())
end

function Game:unit_at(pos)
  for key, unit in pairs(self.units) do
    -- TODO Vector2:is_equal()
    if unit.pos.y == pos.y
        and unit.pos.x == pos.x
    then
      return unit
    end
  end
  return nil
end

-- TODO joint and test this
function Game:add_random_vertical_wall()
  local pos = self.map.get_random_pos()
  local length = math.random(1, 10)
  for i = 0, length do
    if pos.y + i <= self.map.size().y then
      self.map[pos.y + i][pos.x].type = 'block'
    end
  end
end

function Game:add_random_horizontal_wall()
  local pos = self.map.get_random_pos()
  local length = math.random(1, 10)
  for i = 0, length do
    if pos.x + i <= self.map.size().x then
      self.map[pos.y][pos.x + i].type = 'block'
    end
  end
end

function Game:init_test_obstacles()
  for i = 1, 4 do
    self:add_random_vertical_wall()
    self:add_random_horizontal_wall()
  end
end

function Game:init()
  self:init_test_obstacles()
  self:create_units()
  self:update_fov()
  self.screen:init(480, 640, 32)
  -- self.log.add('initialized')
end

function Game:close()
  self.screen:close()
end

function Game:mainloop()
  while self.is_running do
    self.time_system.step()
  end
end

return Game
