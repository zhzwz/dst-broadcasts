--[[
  有限次数、不易获得物品的 prefab 白名单。
  在剩余 1 次使用时提前提醒（见 break.lua）。
  按需增删键即可；值为 true 表示启用。
]]

BROADCASTS_ITEM_STATUS_LAST_USE_WHITELIST = {
  greenamulet = true, -- 建造护符
  greenstaff = true,  -- 解构魔杖
  yellowstaff = true, -- 唤星者魔杖
  opalstaff = true,   -- 唤月者魔杖
  orangestaff = true, -- 懒人魔杖
  telestaff = true,   -- 传送魔杖
  panflute = true,    -- 排箫
  ruins_bat = true,   -- 铥矿棒
}
