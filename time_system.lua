-- See LICENSE file for copyright and license details

local Misc = require 'misc'

local TimeSystem = {}
TimeSystem.__index = TimeSystem

TimeSystem.new = function()
  local self = {
    _actors = {},
    _max_energy = 100
  }
  return setmetatable(self, TimeSystem)
end

TimeSystem._increment_actor_energy = function(self, actor)
  actor:regenerate_energy()
end

TimeSystem._do_actors_turn = function(self)
  for key, actor in pairs(self._actors) do
    if actor:energy() >= self._max_energy then
      actor:callback()
    end
  end
end

TimeSystem._increment_actors_energy = function(self)
  for key, actor in pairs(self._actors) do
    self:_increment_actor_energy(actor)
  end
end

TimeSystem.step = function(self)
  self:_increment_actors_energy()
  self:_do_actors_turn()
end

TimeSystem.add_actor = function(self, actor, id)
  assert(self._actors[id] == nil)
  self._actors[id] = actor
  actor:set_energy(self._max_energy)
end

TimeSystem.remove_actor = function(self, actor_id)
  local key = Misc.id_to_key(self._actors, actor_id)
  self._actors[key] = nil
end

return TimeSystem
