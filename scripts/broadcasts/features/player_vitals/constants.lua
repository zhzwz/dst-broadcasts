--- 玩家状态播报专用常量。

BROADCASTS_PLAYER_VITALS = {
  --- 饱食度过低阈值（current；各档各播一次；文案见 S.player_hunger[threshold]）
  HUNGER_LOW_THRESHOLDS = { 10, 0 },

  --- 理智过低档位（GetPercent，0~1；各档各播一次，文案见对应 messages 键）
  --- 约 50%：可能出现 1 只暗影；约 10%：可能出现 2 只暗影
  SANITY_LOW_TIERS = {
    { threshold = 0.50, messages = "player_low_sanity_50" },
    { threshold = 0.10, messages = "player_low_sanity_10" },
  },

  --- 生命过低阈值（GetPercent，0~1；各档各播一次；文案播实际数值）
  HEALTH_LOW_THRESHOLDS = { 0.10 },

  --- 湿度档位（moisture 当前值；各档各播一次；文案见 S.player_moisture[threshold]）
  MOISTURE_TIERS = {
    { threshold = 10, announce = "ANNOUNCE_DAMP" },
    { threshold = 20, announce = "ANNOUNCE_DAMP" },
    { threshold = 40, announce = "ANNOUNCE_WET" },
    { threshold = 60, announce = "ANNOUNCE_WETTER" },
    { threshold = 80, announce = "ANNOUNCE_SOAKED" },
  },

  --- 温度：与游戏伤害判定一致（过冷 current < 0；过热 current > overheattemp，默认 70）
  TEMPERATURE_FREEZE_DAMAGE = 0,
  TEMPERATURE_OVERHEAT_DAMAGE = 70,
}
