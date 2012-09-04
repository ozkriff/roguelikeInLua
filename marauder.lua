-- See LICENSE file for copyright and license details

-- TODO: Study 'Broken Bottle' and 'Shadow' sources. Looks awesome.
-- TODO: Vec2 class?
-- TODO: colors
-- TODO: Cover *everything* with unit tests
-- TODO: unit types
-- TODO: diagonal move takes more energy!
-- TODO: separate MapModel and MapView
-- TODO: FOV and LOS in C

-- TODO:
-- Test screen module:
-- -- create screen
-- -- draw_something.
-- -- load .png with expected image
-- -- compare pixels of this surfaces

local TimeSystem = require 'time_system'
local Screen = require 'screen'
local Log = require 'log'
local Map = require 'map'
local Pathfinder = require 'pathfinder'
local Game = require 'game'

function main()
  math.randomseed(os.time())
  local screen = Screen.new()

  local map = Map.new()
  map:set_size({y = 15, x = 15}) -- in tiles
  -- map.pos = {y = 1, x = 1} -- TODO: in pixels
  map.screen = screen -- TODO: map_viewer

  local pathfinder = Pathfinder.new(map)

  local log = Log()
  log.set_pos({y = 300, x = 10}) -- in pixels
  log.set_screen(screen) -- TODO: log viewer?

  local time_system = TimeSystem()
  local game = Game.new(screen, map,
      pathfinder, log, time_system)
  -- TODO use setters for screen, map, etc variable
  -- TODO assert() that thay all set in init() method
  game:init()
  game:mainloop()
  game:close()
end

main()
