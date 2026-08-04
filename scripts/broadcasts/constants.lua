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

  -- Pearl 状态查询：成功播报后同一玩家的最短间隔（秒）
  PEARL_STATUS_COOLDOWN_SECONDS = 30,

  -- Pearl 状态查询：未找到/失败后的短冷却（秒），防止刷屏
  PEARL_STATUS_FAIL_COOLDOWN_SECONDS = 8,

  -- Pearl 跨分片查询：等待其他分片回复的超时（秒）
  PEARL_STATUS_SHARD_TIMEOUT_SECONDS = 1.5,
}
