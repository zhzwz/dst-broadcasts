-- spell:ignore autum
--[[
  Pearl 任务 id 与文案键，需与游戏 prefabs/hermitcrab.lua 中 TASKS 保持一致。
  key 对应 BROADCASTS_STRINGS.pearl_tasks。
]]

BROADCASTS_PEARL_TASKS = {
  { id = 1,  key = "FIX_HOUSE_1" },       -- 修房子（1 级）
  { id = 2,  key = "FIX_HOUSE_2" },       -- 修房子（2 级）
  { id = 3,  key = "FIX_HOUSE_3" },       -- 修房子（3 级）
  { id = 4,  key = "PLANT_FLOWERS" },     -- 种花
  { id = 5,  key = "REMOVE_JUNK" },       -- 清理海底垃圾
  { id = 6,  key = "PLANT_BERRIES" },     -- 整理浆果丛（施肥）
  { id = 7,  key = "FILL_MEATRACKS" },    -- 晾肉架挂满
  { id = 8,  key = "GIVE_HEAVY_FISH" },   -- 送 5 条重海鱼
  { id = 9,  key = "REMOVE_LUREPLANT" },  -- 清除食人花
  { id = 10, key = "GIVE_UMBRELLA" },     -- 下雨时送伞
  { id = 11, key = "GIVE_PUFFY_VEST" },   -- 下雪时送保温衣
  { id = 12, key = "GIVE_FLOWER_SALAD" }, -- 送花沙拉
  { id = 14, key = "GIVE_BIG_WINTER" },   -- 送冬季重鱼
  { id = 15, key = "GIVE_BIG_SUMMER" },   -- 送夏季重鱼
  { id = 16, key = "GIVE_BIG_SPRING" },   -- 送春季重鱼
  { id = 17, key = "GIVE_BIG_AUTUM" },    -- 送秋季重鱼（游戏拼写为 AUTUM）
  { id = 18, key = "MAKE_CHAIR" },        -- 做木椅并让她坐下
}
