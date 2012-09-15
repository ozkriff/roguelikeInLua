local Assert = require 'assert'
local Game = require 'game'
local Symbols = require 'symbols'

local function test_unittype_to_char()
  local game = Game.new()
  Assert.is_equal(game.unit_type_to_char('player'),
      Symbols.AT)
  Assert.is_equal(game.unit_type_to_char('enemy'),
      Symbols.Z)
  Assert.is_nil(game.unit_type_to_char('ololo'))
end

return function()
  test_unittype_to_char()
end
