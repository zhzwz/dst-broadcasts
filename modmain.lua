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

if GetModConfigData("usage_break_enabled") then
  modimport("scripts/broadcasts/usage_break.lua")
  modimport("scripts/broadcasts/equipment_break.lua")
end

modimport("scripts/broadcasts/features/player_vitals/init.lua")
modimport("scripts/broadcasts/features/attack_warning/init.lua")

if GetModConfigData("cave_events_enabled") then
  modimport("scripts/broadcasts/cave_events.lua")
end

modimport("scripts/broadcasts/frog_rain.lua")

if GetModConfigData("morning_news_enabled") then
  modimport("scripts/broadcasts/morning_news.lua")
end

if GetModConfigData("boss_defeat_enabled") then
  modimport("scripts/broadcasts/boss_defeat.lua")
end

if GetModConfigData("pearl_status_enabled") then
  modimport("scripts/broadcasts/pearl_status.lua")
end

if GetModConfigData("drone_delivery_enabled") then
  modimport("scripts/broadcasts/drone_delivery.lua")
end
