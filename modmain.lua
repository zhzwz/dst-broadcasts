--[[
  dst-warnings：可扩展的全服提醒框架。
  新增提醒：在 scripts/warnings/ 下加模块，并在此 modimport。
]]

GLOBAL.setmetatable(env, { __index = function(_, k) return GLOBAL.rawget(GLOBAL, k) end })

modimport("scripts/warnings/attack_countdown.lua")

if GetModConfigData("usage_break_enabled") then
    modimport("scripts/warnings/usage_break.lua")
    modimport("scripts/warnings/equipment_break.lua")
end

if GetModConfigData("hounded_enabled") then
    modimport("scripts/warnings/hounded.lua")
end

if GetModConfigData("hassler_boss_enabled") then
    modimport("scripts/warnings/hassler_boss.lua")
end

if GetModConfigData("static_boss_enabled") then
    modimport("scripts/warnings/static_boss.lua")
end
