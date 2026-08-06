--- 玩家状态入口：饱食、理智、生命、温度、湿度。
--- 细项开关在此判断；modmain 只需 modimport 本文件。

local hunger = GetModConfigData("player_hunger_enabled")
local sanity = GetModConfigData("player_sanity_enabled")
local health = GetModConfigData("player_health_enabled")
local temperature = GetModConfigData("player_temperature_enabled")
local moisture = GetModConfigData("player_moisture_enabled")

if not (hunger or sanity or health or temperature or moisture) then
  return
end

modimport("scripts/broadcasts/features/player_vitals/constants.lua")

if hunger then
  modimport("scripts/broadcasts/features/player_vitals/hunger.lua")
end
if sanity then
  modimport("scripts/broadcasts/features/player_vitals/sanity.lua")
end
if health then
  modimport("scripts/broadcasts/features/player_vitals/health.lua")
end
if temperature then
  modimport("scripts/broadcasts/features/player_vitals/temperature.lua")
end
if moisture then
  modimport("scripts/broadcasts/features/player_vitals/moisture.lua")
end
