local Log = require 'log'
local Assert = require 'assert'
local Screen = require 'screen'
local LogViewer = require 'log_viewer'

local function test_draw()
  local screen = Screen.new()
  local log = Log.new()
  log:add('STRING-1')
  log:add('str-2')
  log:add('str-3')
  log:add('str-4')
  local log_viewer = LogViewer.new()
  log_viewer:set_log(log)
  log_viewer:set_pos{y = 2, x = 2}
  log_viewer:set_screen(screen)
  log_viewer:set_max_size(3)
  screen:init({y = 64, x = 64}, 32)
  screen:clear()
  log_viewer:draw()
  local filename = 'test/img/log_viewer_1.png'
  Assert.is_true(screen:compare(filename))
end

return function()
  test_draw()
end
