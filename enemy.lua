-- See LICENSE file for copyright and license details

local Misc = require 'misc'

local Enemy = {}
Enemy.__index = Enemy

function Enemy:enemy_move_to_player()
  -- TODO
end

function Enemy:get_new_pos_simple()
  local g = self.game
  local pos = {y = self.pos.y, x = self.pos.x}
  -- TODO replace with dijkstra or a-star
  if g.player.pos.x < self.pos.x then
    pos.x = self.pos.x - 1
  end
  if g.player.pos.x > self.pos.x then
    pos.x = self.pos.x + 1
  end
  if g.player.pos.y < self.pos.y then
    pos.y = self.pos.y - 1
  end
  if g.player.pos.y > self.pos.y then
    pos.y = self.pos.y + 1
  end
  return pos
end

function Enemy:get_new_pos_djikstra()
  local g = self.game
  local pf = g.pathfinder
  local pos
  local path = pf:get_path(self.pos, g.player.pos)
  assert(#path >= 2)
  return path[2]
end

function Enemy:do_turn()
  local g = self.game
  -- print 'Enemy:do_enemy_turn()'
  if Misc.distance(g.player.pos, self.pos) == 1 then
    g.log:add('Enemy attacking you!')
    self.energy = self.energy - g.action_cost.fire
    return
  end
  local dist = Misc.distance(g.player.pos, self.pos)
  if dist < g.max_see_distance then
    -- local new_pos = self:get_new_pos_djikstra()
    local new_pos = self:get_new_pos_simple()
    if g:is_position_free(new_pos) then
      g.map[self.pos.y][self.pos.x].unit = nil
      self.pos = new_pos
      g.map[self.pos.y][self.pos.x].unit = true
      self.energy = self.energy - g.action_cost.move
    else
      self.energy = self.energy - g.action_cost.wait
    end
    g.map:clamp_pos(self.pos)
  else
    self.energy = self.energy - g.action_cost.wait
  end
end

function Enemy.new()
  local new_enemy = {
    type = 'enemy',
    callback = Enemy.do_turn,
    energy_regeneration = 5
  }
  return setmetatable(new_enemy, Enemy)
end

return Enemy
