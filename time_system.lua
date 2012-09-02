-- See LICENSE file for copyright and license details

local Misc = require 'misc'

local TimeSystem = {}
TimeSystem.__index = TimeSystem

function TimeSystem.new()
  local new_ts = {}
  new_ts.actors = {}
  new_ts.max_energy = 100
  return setmetatable(new_ts, TimeSystem)
end

local function increment_actor_energy(actor)
  actor.energy = actor.energy + actor.energy_regeneration
end

function TimeSystem:do_actors_turn()
  for key, actor in pairs(self.actors) do
    if actor.energy >= self.max_energy then
      assert(actor.callback)
      actor:callback()
    end
  end
end

function TimeSystem:increment_actors_energy()
  for key, actor in pairs(self.actors) do
    increment_actor_energy(actor)
  end
end

function TimeSystem:step()
  self:increment_actors_energy()
  self:do_actors_turn()
end

function TimeSystem:add_actor(actor, id)
  assert(self.actors[id] == nil)
  self.actors[id] = actor;
  actor.energy = self.max_energy
end

function TimeSystem:remove_actor(actor_id)
  local key = Misc.id_to_key(self.actors, actor_id)
  self.actors[key] = nil
end

return TimeSystem
