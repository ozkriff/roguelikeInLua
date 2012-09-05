-- See LICENSE file for copyright and license details
local Misc = require 'misc'


return function(game)
  local self = {}

  local energy_regeneration = 10
  local type = 'player'
  local game = game
  local pos = {y = 1, x = 1}
  local energy

  self.type = function()
    return type
  end

  self.energy = function()
    return energy
  end

  self.set_energy = function(new_energy)
    energy = new_energy
  end

  self.regenerate_energy = function()
    energy = energy + energy_regeneration
  end

  self.pos = function()
    return pos
  end

  self.set_pos = function(new_pos)
    pos = new_pos
  end

  local explosion = function()
    -- TODO player need rifle to shoot!
    -- TODO extruct to kill_unit function
    game.log.add('firing')
    energy = energy - game.action_cost.fire
    for key, enemy in pairs(game.units) do
      local d = Misc.distance(pos, enemy.pos)
      if enemy ~= self and d <= 4 then
        game.log.add('killed ' .. key)
        game.time_system.remove_actor(enemy.id)
        table.remove(game.units, key)
      end
    end
  end

  -- TODO: Rename
  local directions = {
    h = 'left',
    j = 'down',
    k = 'up',
    l = 'right',
    y = 'up_left',
    u = 'up_right',
    b = 'down_left',
    n = 'down_right'
  }

  local direction_to_diff_map = {
    up = {x = 0, y = -1},
    up_right = {x = 1, y = -1},
    right = {x = 1, y = 0},
    down_right = {x = 1, y = 1},
    down = {x = 0, y = 1},
    down_left = {x = -1, y = 1},
    left = {x = -1, y = 0},
    up_left = {x = -1, y = -1},
  }

  -- TODO
  local fire = function()
    local char = ' '
    local cursor_pos = {y = pos.y, x = pos.x}
    -- game.screen:move(
    --     game.map.pos.y + pos.y,
    --     game.map.pos.x + pos.x)
    -- game.screen:move(pos.y, pos.x)
    -- game.screen:refresh()
    while char ~= 'f' do
      if directions[char] then
        cursor_pos.x = cursor_pos.x
            + direction_to_diff_map[directions[char]].x
        cursor_pos.y = cursor_pos.y
            + direction_to_diff_map[directions[char]].y
        game.map.clamp_pos(cursor_pos)
        -- game.screen:move(
        --     game.map.pos.y + pos.y,
        --     game.map.pos.x + pos.x)
        -- game.screen:move(cursor_pos.y, cursor_pos.x)
        -- game.screen:refresh()
      end
      char = game:get_next_command()
    end

    -- TODO bresenham

    local enemy = game:unit_at(cursor_pos)

    if not enemy then
      game.log.add('No one here!')
      return
    end

    game.log.add('firing')
    energy = energy - game.action_cost.fire

    local d = Misc.distance(pos, enemy.pos())

    -- TODO: extruct to Game:kill_unit(id)
    game.log.add('killed ' .. enemy.id)
    game.time_system.remove_actor(enemy.id)
    local key = Misc.id_to_key(game.units, enemy.id)
    table.remove(game.units, key)
  end

  local move = function(direction)
    local new_pos = {
      y = pos.y + direction_to_diff_map[direction].y,
      x = pos.x + direction_to_diff_map[direction].x
    }
    game.map.clamp_pos(new_pos)
    if game:is_position_free(new_pos) then
      game.map[pos.y][pos.x].unit = nil
      pos = new_pos
      game.map[pos.y][pos.x].unit = true
      game:update_fov()
      game.log.add('moved ' .. direction)
      energy = energy - game.action_cost.move
    else
      game.log.add('waiting')
      energy = energy - game.action_cost.wait
    end
  end

  local do_command = function(char)
    if char == 'q' then
      game.is_running = false
    elseif directions[char] then
      move(directions[char])
    elseif char == '.' then
      game.log.add('waiting')
      energy = energy - game.action_cost.wait
    elseif char == 'f' then
      fire()
    end
  end

  self.callback = function()
    game:draw()
    do_command(game:get_next_command())
    game:draw()
  end

  return self
end
