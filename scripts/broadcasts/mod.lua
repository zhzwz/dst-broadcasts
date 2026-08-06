mod = mod or {}

--- @param value unknown
--- @param default number?
--- @return number
mod.FormatNumber = function(value, default)
  if type(value) == "number" then return value end
  return tonumber(value) or default or 0
end

modimport("scripts/broadcasts/mod/call.lua")
modimport("scripts/broadcasts/mod/wrap.lua")
modimport("scripts/broadcasts/mod/trim.lua")
modimport("scripts/broadcasts/mod/print.lua")
modimport("scripts/broadcasts/mod/random.lua")
modimport("scripts/broadcasts/mod/constants.lua")

modimport("scripts/broadcasts/mod/announce.lua")
modimport("scripts/broadcasts/mod/entity.lua")
modimport("scripts/broadcasts/mod/player.lua")
modimport("scripts/broadcasts/mod/item.lua")
modimport("scripts/broadcasts/mod/character.lua")
modimport("scripts/broadcasts/mod/prefab.lua")

modimport("scripts/broadcasts/mod/world.lua")
modimport("scripts/broadcasts/mod/world_weather.lua")
modimport("scripts/broadcasts/mod/shard.lua")

mod.Watch = mod.Watch or {}
modimport("scripts/broadcasts/mod/watch_cycles.lua")
