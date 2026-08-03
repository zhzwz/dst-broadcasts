--[[
  青蛙雨播报专用常量。
]]

BROADCASTS_FROG_RAIN = {
  -- 持久化状态键（勿改名，避免存档计数丢失）
  ACTIVE_KEY = "frog_rain_active",
  COUNT_KEY = "frog_rain_count",
  LUNAR_COUNT_KEY = "frog_rain_lunar_count",

  FROG_PREFAB = "frog",
  LUNAR_FROG_PREFAB = "lunarfrog",

  -- 实体去重标记（内存，不入档）
  COUNTED_FLAG = "_dst_broadcasts_frog_counted",
}
