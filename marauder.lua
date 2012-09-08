#!env lua
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

local Log = require 'log'
local Map = require 'map'
local Game = require 'game'
local Screen = require 'screen'
local Pathfinder = require 'pathfinder'
local TimeSystem = require 'time_system'

function main()
  math.randomseed(os.time())
  local screen = Screen.new()

  local map = Map.new()
  map:set_size({y = 15, x = 15}) -- in tiles
  -- map.set_pos({y = 1, x = 1}) -- TODO: in pixels
  map:set_screen(screen) -- TODO: map_viewer

  local pathfinder = Pathfinder.new(map)

  local log = Log.new()
  log:set_pos({y = 300, x = 10}) -- in pixels
  log:set_screen(screen) -- TODO: log viewer?

  local time_system = TimeSystem.new()
  local game = Game.new()
  game:set_screen(screen)
  game:set_map(map)
  game:set_pathfinder(pathfinder)
  game:set_log(log)
  game:set_time_system(time_system)
  game:init()
  game:mainloop()
  game:close()
end

main()
