-- See LICENSE file for copyright and license details

local Tr = {}

local locales = {
  rus = require 'tr/rus',
  -- ger = require 'tr/ger',
}

function Tr.new(lang)
  local locale = nil
  if lang and locales[lang] then
    locale = locales[lang]
  end
  return function(str)
    if locale then
      return locale[str] or str
    else
      return str
    end
  end
end

return Tr
