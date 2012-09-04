-- See LICENSE file for copyright and license details

local Misc = require 'misc'

return function()
  local self = {}

  local actors = {}
  local max_energy = 100

  local increment_actor_energy = function(actor)
    actor.energy = actor.energy + actor.energy_regeneration
  end

  local do_actors_turn = function()
    for key, actor in pairs(actors) do
      if actor.energy >= max_energy then
        assert(actor.callback)
        actor:callback()
      end
    end
  end

  local increment_actors_energy = function()
    for key, actor in pairs(actors) do
      increment_actor_energy(actor)
    end
  end

  self.step = function()
    increment_actors_energy()
    do_actors_turn()
  end

  self.add_actor = function(actor, id)
    assert(actors[id] == nil)
    actors[id] = actor
    actor.energy = max_energy
  end

  self.remove_actor = function(actor_id)
    local key = Misc.id_to_key(actors, actor_id)
    actors[key] = nil
  end

  return self
end
