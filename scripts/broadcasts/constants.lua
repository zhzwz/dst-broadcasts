--[[
  模组可调常量。修改阈值/间隔时优先改这里。
]]

BROADCASTS_CONSTANTS = {
  -- 日志前缀
  LOG_PREFIX = "[Broadcasts]",

  -- 季节循环：当前季节 -> 下一季节（日历播报）
  NEXT_SEASON = {
    autumn = "winter",
    winter = "spring",
    spring = "summer",
    summer = "autumn",
  },

  -- 巨兽击败后伤害排行最多播报人数
  BOSS_DAMAGE_RANKING_MAX = 10,
}
