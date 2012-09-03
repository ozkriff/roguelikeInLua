-- See LICENSE file for copyright and license details
local Misc = require 'misc'

local Player = {}
Player.__index = Player

function Player:explosion()
  -- TODO player need rifle to shoot!
  -- TODO extruct to kill_unit function
  local g = self.game
  g.log:add('firing')
  self.energy = self.energy - g.action_cost.fire
  for key, enemy in pairs(g.units) do
    local d = Misc.distance(self.pos, enemy.pos)
    if enemy ~= self and d <= 4 then
      g.log:add('killed ' .. key)
      g.time_system:remove_actor(enemy.id)
      table.remove(g.units, key)
    end
  end
end

-- TODO: Rename
local directions = {
  h = 'left',
  j = 'down',
  k = 'up',
  l = 'right',
  y = 'up_left',
  u = 'up_right',
  b = 'down_left',
  n = 'down_right'
}

local direction_to_diff_map = {
  up = {x = 0, y = -1},
  up_right = {x = 1, y = -1},
  right = {x = 1, y = 0},
  down_right = {x = 1, y = 1},
  down = {x = 0, y = 1},
  down_left = {x = -1, y = 1},
  left = {x = -1, y = 0},
  up_left = {x = -1, y = -1},
}

-- TODO
function Player:fire()
  local g = self.game
  local char = ' '
  local pos = {y = self.pos.y, x = self.pos.x}
  -- g.screen:move(
  --     g.map.pos.y + pos.y,
  --     g.map.pos.x + pos.x)
  -- g.screen:move(pos.y, pos.x)
  -- g.screen:refresh()
  while char ~= 'f' do
    if directions[char] then
      local new_pos = {}
      pos.x = pos.x + direction_to_diff_map[directions[char]].x
      pos.y = pos.y + direction_to_diff_map[directions[char]].y
      g.map:clamp_pos(pos)
      -- g.screen:move(
      --     g.map.pos.y + pos.y,
      --     g.map.pos.x + pos.x)
      -- g.screen:move(pos.y, pos.x)
      -- g.screen:refresh()
    end
    char = g:get_next_command()
  end

  -- TODO bresenham

  local enemy = g:unit_at(pos)

  if not enemy then
    g.log:add('No one here!')
    return
  end

  g.log:add('firing')
  self.energy = self.energy - g.action_cost.fire

  local d = Misc.distance(self.pos, enemy.pos)

  -- TODO: extruct to Game:kill_unit(id)
  g.log:add('killed ' .. enemy.id)
  g.time_system:remove_actor(enemy.id)
  local key = Misc.id_to_key(g.units, enemy.id)
  table.remove(g.units, key)
end

function Player:move(direction)
  local g = self.game
  local new_pos = {}
  new_pos.x = self.pos.x
      + direction_to_diff_map[direction].x
  new_pos.y = self.pos.y
      + direction_to_diff_map[direction].y
  g.map:clamp_pos(new_pos)
  if g:is_position_free(new_pos) then
    g.map[self.pos.y][self.pos.x].unit = nil
    self.pos = new_pos
    g.map[self.pos.y][self.pos.x].unit = true
    g:update_fov()
    g.log:add('moved ' .. direction)
    self.energy = self.energy - g.action_cost.move
  else
    g.log:add('waiting')
    self.energy = self.energy - g.action_cost.wait
  end
end

function Player:do_command(char)
  local g = self.game
  if char == 'q' then
    g.is_running = false
  elseif directions[char] then
    self:move(directions[char])
  elseif char == '.' then
    g.log:add('waiting')
    self.energy = self.energy - g.action_cost.wait
  elseif char == 'f' then
    self:fire()
  end
end

function Player:do_turn()
  local g = self.game
  g:draw()
  self:do_command(g:get_next_command())
  g:draw()
end

-- TODO: do not pass table as arg
function Player.new()
  local new_player = {
    type = 'player',
    callback = Player.do_turn,
    energy_regeneration = 10
  }
  return setmetatable(new_player, Player)
end

return Player
