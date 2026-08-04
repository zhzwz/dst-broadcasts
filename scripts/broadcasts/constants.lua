--[[
  模组可调常量。修改阈值/间隔时优先改这里。
]]

BROADCASTS_CONSTANTS = {
  -- 日志与调试播报前缀
  LOG_PREFIX = "[Broadcasts]",

  -- 调试模式开启时，播报到聊天的最大字节数（超出截断并加 "..."）
  DEBUG_CHAT_MAX = 400,

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
