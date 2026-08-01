--[[
  dst-broadcasts：可扩展的全服播报框架。
  新增模块：在 scripts/broadcasts/ 下添加，并在此 modimport。
]]

GLOBAL.setmetatable(env, { __index = function(_, k) return GLOBAL.rawget(GLOBAL, k) end })

modimport("scripts/broadcasts/strings.lua")
modimport("scripts/broadcasts/constants.lua")
modimport("scripts/broadcasts/safe.lua")
modimport("scripts/broadcasts/attack_warning.lua")

AddPrefabPostInit("world", function(inst)
    if inst.ismastersim then
        inst:AddComponent("state_3774915634")
    end
end)

if GetModConfigData("usage_break_enabled") then
    modimport("scripts/broadcasts/usage_break.lua")
    modimport("scripts/broadcasts/equipment_break.lua")
end

if GetModConfigData("hounded_enabled") then
    modimport("scripts/broadcasts/hounded.lua")
end

if GetModConfigData("cave_events_enabled") then
    modimport("scripts/broadcasts/cave_events.lua")
end

if GetModConfigData("frog_rain_enabled") then
    modimport("scripts/broadcasts/frog_rain.lua")
end

if GetModConfigData("hassler_boss_enabled") then
    modimport("scripts/broadcasts/hassler_boss.lua")
end

if GetModConfigData("morning_news_enabled") then
    modimport("scripts/broadcasts/morning_news.lua")
end

if GetModConfigData("boss_defeat_enabled") then
    modimport("scripts/broadcasts/boss_defeat.lua")
end
