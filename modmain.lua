--[[
  dst-broadcasts：可扩展的全服播报框架。
  新增模块：在 scripts/broadcasts/ 下添加，并在此 modimport。
]]

GLOBAL.setmetatable(env, { __index = function(_, k) return GLOBAL.rawget(GLOBAL, k) end })

modimport("scripts/broadcasts/language/init.lua")
modimport("scripts/broadcasts/constants.lua")
modimport("scripts/broadcasts/safe.lua")

AddPrefabPostInit("world", function(inst)
  if inst.ismastersim then
    inst:AddComponent("state_3774915634")
  end
end)

modimport("scripts/broadcasts/features/item_status/init.lua")
modimport("scripts/broadcasts/features/player_vitals/init.lua")
modimport("scripts/broadcasts/features/attack_warning/init.lua")
modimport("scripts/broadcasts/features/frog_rain/init.lua")
modimport("scripts/broadcasts/features/calendar/init.lua")
modimport("scripts/broadcasts/features/harvest/init.lua")
modimport("scripts/broadcasts/features/portable_storage/init.lua")
modimport("scripts/broadcasts/features/pearl/init.lua")

if GetModConfigData("cave_events_enabled") then
  modimport("scripts/broadcasts/cave_events.lua")
end

if GetModConfigData("boss_defeat_enabled") then
  modimport("scripts/broadcasts/boss_defeat.lua")
end
