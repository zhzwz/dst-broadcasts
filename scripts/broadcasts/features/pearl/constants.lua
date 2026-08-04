--[[
  Pearl（寄居蟹隐士）播报专用常量。
]]

BROADCASTS_PEARL = {
  -- 成功播报后同一玩家的最短间隔（秒）
  COOLDOWN_SECONDS = 30,

  -- 未找到/失败后的短冷却（秒），防止刷屏
  FAIL_COOLDOWN_SECONDS = 8,

  -- 跨分片查询：等待其他分片回复的超时（秒）
  SHARD_TIMEOUT_SECONDS = 1.5,
}
