--[[
  dst-warnings：可扩展的全服提醒框架。
  新增提醒：在 scripts/warnings/ 下加模块，并在此 modimport。
]]

GLOBAL.setmetatable(env, { __index = function(_, k) return GLOBAL.rawget(GLOBAL, k) end })

if GetModConfigData("usage_break_enabled") then
    modimport("scripts/warnings/usage_break.lua")
end

if GetModConfigData("hounded_enabled") then
    modimport("scripts/warnings/hounded.lua")
end
