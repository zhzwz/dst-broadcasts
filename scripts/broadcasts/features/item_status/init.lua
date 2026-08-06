--- 物品状态入口：耐久、燃料、损毁、损毁预警。
--- 细项开关在此判断；modmain 只需 modimport 本文件。

local durability = GetModConfigData("item_durability_enabled")
local fuel = GetModConfigData("item_fuel_enabled")
local item_break = GetModConfigData("item_break_enabled")
local break_warning = GetModConfigData("item_break_warning_enabled")

if not (durability or fuel or item_break or break_warning) then
  return
end

BROADCASTS_ITEM_STATUS = {
  DURABILITY = durability == true,
  FUEL = fuel == true,
  BREAK = item_break == true,
  BREAK_WARNING = break_warning == true,
}

modimport("scripts/broadcasts/features/item_status/constants.lua")

if durability or fuel then
  modimport("scripts/broadcasts/features/item_status/fueled.lua")
end
if item_break or break_warning then
  if break_warning then
    modimport("scripts/broadcasts/features/item_status/last_use_whitelist.lua")
  end
  modimport("scripts/broadcasts/features/item_status/break.lua")
end
