-- See LICENSE file for copyright and license details

local Misc = require 'misc'

local Assert = {}

function Assert.is_equal(real, expected)
  assert(real)
  assert(expected)
  assert(Misc.deepcompare(real, expected),
      'Expected <<< ' .. Misc.dump(expected) .. ' >>>, ' ..
      'but got <<< ' .. Misc.dump(real) .. ' >>>')
end

function Assert.is_true(real)
  assert(real)
end

function Assert.is_false(real)
  assert(not real)
end

function Assert.is_nil(real)
  assert(real == nil,
      'Expected nil but got ' .. (real or 'nil'))
end

return Assert
