--[[
  袭击预警专用常量。
]]

BROADCASTS_ATTACK_WARNING = {
  -- 现实时间阈值（秒）。须与 language 文案中 durations 的键一致
  REAL_THRESHOLDS = { 480, 240, 120, 60, 30, 10, 5 },

  -- 倒计时轮询间隔（秒）
  POLL_SECONDS = 1,

  -- 猎犬/蠕虫「已开始袭击」检测轮询间隔（秒）
  HOUNDED_ATTACK_POLL_SECONDS = 1,

  -- worldsettingstimer 计时器名
  DEERCLOPS_TIMER = "deerclops_timetoattack",
  BEARGER_TIMER = "bearger_timetospawn",
}
