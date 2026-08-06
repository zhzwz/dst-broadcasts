--- 物品状态入口：耐久、燃料、损毁、损毁预警。
--- 永久开启；modmain 只需 modimport 本文件。

BROADCASTS_ITEM_STATUS = {
  DURABILITY = true,
  FUEL = true,
  BREAK = true,
  BREAK_WARNING = true,
}

modimport("scripts/broadcasts/features/item_status/constants.lua")
modimport("scripts/broadcasts/features/item_status/fueled.lua")
modimport("scripts/broadcasts/features/item_status/last_use_whitelist.lua")
modimport("scripts/broadcasts/features/item_status/break.lua")
