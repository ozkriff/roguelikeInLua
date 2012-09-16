#!env lua
-- See LICENSE file for copyright and license details

-- load file and run returned function
local run_test_suite = function(filename)
  print('running: ' .. filename)
  require(filename)()
end

local function run()
  run_test_suite 'test/misc'
  run_test_suite 'test/game'
  run_test_suite 'test/screen'
  run_test_suite 'test/time_system'
  run_test_suite 'test/map'
  run_test_suite 'test/bresenham'
  run_test_suite 'test/priority_queue'
  run_test_suite 'test/tr'
  run_test_suite 'test/log'
  -- run_test_suite 'test/log_viewer'
  -- run_test_suite 'test/pathfinder'
  print('All tests are Ok')
end

run()
