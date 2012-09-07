-- See LICENSE file for copyright and license details

local Misc = require 'misc'

return function(game)
  local self = {}

  local energy_regeneration = 5
  local type = 'enemy'
  local game = game
  local pos = {y = 1, x = 1}
  local energy

  self.type = function()
    return type
  end

  self.energy = function()
    return energy
  end

  self.set_energy = function(new_energy)
    energy = new_energy
  end

  self.regenerate_energy = function()
    energy = energy + energy_regeneration
  end

  self.pos = function()
    return pos
  end

  self.set_pos = function(new_pos)
    pos = new_pos
  end

  local get_new_pos_simple = function()
    local p = Misc.copy(pos)
    local destination = game.player().pos()
    if destination.x < p.x then
      p.x = p.x - 1
    end
    if destination.x > p.x then
      p.x = p.x + 1
    end
    if destination.y < p.y then
      p.y = p.y - 1
    end
    if destination.y > p.y then
      p.y = p.y + 1
    end
    return p
  end

  local get_new_pos_djikstra = function()
    local path = game.pathfinder().get_path(
        pos, game.player().pos())
    assert(#path >= 2)
    return path[2]
  end

  self.callback = function()
    if Misc.distance(game.player().pos(), pos) == 1 then
      game.log().add('Enemy attacking you!')
      energy = energy - game.action_cost().fire
      return
    end
    local dist = Misc.distance(game.player().pos(), pos)
    if dist < game.max_see_distance() then
      -- local new_pos = get_new_pos_djikstra()
      local new_pos = get_new_pos_simple()
      if game.is_position_free(new_pos) then
        game.map()[pos.y][pos.x].unit = nil
        pos = new_pos
        game.map()[pos.y][pos.x].unit = true
        energy = energy - game.action_cost().move
      else
        energy = energy - game.action_cost().wait
      end
      game.map().clamp_pos(pos)
    else
      energy = energy - game.action_cost().wait
    end
  end

  return self
end
