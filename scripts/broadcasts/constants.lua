--[[
  模组可调常量。修改阈值/间隔时优先改这里。
]]

BROADCASTS_CONSTANTS = {
  -- 日志与调试播报前缀
  LOG_PREFIX = "[Broadcasts]",

  -- 调试模式开启时，播报到聊天的最大字节数（超出截断并加 "..."）
  DEBUG_CHAT_MAX = 400,

  -- 可缝补物品（FUELTYPE.USAGE）耐久播报阈值（百分比）
  USAGE_SEW_THRESHOLDS = { 20, 10, 5, 4, 3, 2, 1 },

  -- 可补充燃料物品的燃料播报阈值（百分比）
  USAGE_FUEL_THRESHOLDS = { 30, 20, 10 },

  -- 玩家饱食度 / 理智过低播报阈值（当前值；各档各播一次）
  PLAYER_STAT_LOW_THRESHOLDS = { 10, 0 },

  -- 玩家生命过低播报阈值（GetPercent，0~1；各档各播一次）
  PLAYER_HEALTH_LOW_THRESHOLDS = { 0.20, 0.10 },

  -- 永恒早报：剩余季节天数等于该值时，播报“明日换季”
  MORNING_SEASON_CHANGE_REMAINING_DAYS = 1,

  -- 季节循环：当前季节 -> 下一季节
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
