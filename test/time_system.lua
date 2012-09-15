local Assert = require 'assert'
local TimeSystem = require 'time_system'

local function test_time_system()
  local buffer = ''
  local function create_mock_actor(id, energy_regeneration)
    return {
      _energy = 0,
      _energy_regeneration = energy_regeneration,
      id = id,
      regenerate_energy = function(self)
        self._energy = self._energy + self._energy_regeneration
      end,
      set_energy = function(self, energy)
        self._energy = self._energy + energy
      end,
      energy = function(self)
        return self._energy
      end,
      callback = function(self)
        buffer = buffer .. tostring(self.id)
        self._energy = self._energy - 20
      end
    }
  end
  local time_system = TimeSystem.new()
  time_system:add_actor(create_mock_actor(1, 10), 1)
  time_system:add_actor(create_mock_actor(2, 5), 2)
  for i = 1, 21 do
    buffer = buffer .. '{'
    time_system:step()
    buffer = buffer .. '}'
  end
  Assert.is_equal(buffer, '{12}' .. string.rep('{1}{}{12}{}', 5))
end

return function()
  test_time_system()
end
