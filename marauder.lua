#!env lua
-- See LICENSE file for copyright and license details

local Log = require 'log'
local Map = require 'map'
local Game = require 'game'
local Screen = require 'screen'
local LogViewer = require 'log_viewer'
local Pathfinder = require 'pathfinder'
local TimeSystem = require 'time_system'

function main()
  math.randomseed(os.time())
  local screen = Screen.new()
  local map = Map.new()
  map:set_size({y = 15, x = 15}) -- in tiles
  -- map.set_pos({y = 1, x = 1}) -- TODO: in pixels
  map:set_screen(screen) -- TODO: map_viewer
  local pathfinder = Pathfinder.new()
  pathfinder:set_map(map)
  local log = Log.new()
  local log_viewer = LogViewer.new()
  log_viewer:set_log(log)
  log_viewer:set_pos({y = 300, x = 10})
  log_viewer:set_screen(screen)
  local time_system = TimeSystem.new()
  local game = Game.new()
  game:set_screen(screen)
  game:set_map(map)
  game:set_pathfinder(pathfinder)
  game:set_log(log)
  game:set_log_viewer(log_viewer)
  game:set_time_system(time_system)
  game:init()
  game:mainloop()
  game:close()
end

main()
