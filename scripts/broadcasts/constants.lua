--[[
  模组可调常量。修改阈值/间隔时优先改这里。
]]

BROADCASTS_CONSTANTS = {
    -- 日志与调试公告前缀
    LOG_PREFIX = "[Broadcasts]",

    -- 调试模式开启时，公告到聊天的最大字节数（超出截断并加 "..."）
    DEBUG_CHAT_MAX = 400,

    -- 袭击预警：提前多少个游戏日提醒（1 = 剩余 ≤ 1 游戏日时提醒）
    ATTACK_WARNING_ADVANCE_DAYS = 1,

    -- 袭击预警：现实时间阈值（秒）。须与 strings.lua 中 durations 的键一致
    ATTACK_WARNING_REAL_THRESHOLDS = { 300, 120, 60, 30, 10, 5 },

    -- 袭击预警轮询间隔（秒）
    ATTACK_WARNING_POLL_SECONDS = 1,

    -- 猎犬/蠕虫“已开始袭击”检测轮询间隔（秒）
    HOUNDED_ATTACK_POLL_SECONDS = 1,

    -- 可缝补物品（FUELTYPE.USAGE）耐久提醒阈值（百分比）
    USAGE_SEW_THRESHOLDS = { 20, 10, 5, 4, 3, 2, 1 },

    -- 可补充燃料物品的燃料提醒阈值（百分比）
    USAGE_FUEL_THRESHOLDS = { 30, 20, 10 },

    -- 永恒早报：剩余季节天数等于该值时，提示“明日换季”
    MORNING_SEASON_CHANGE_REMAINING_DAYS = 1,

    -- 季节循环：当前季节 -> 下一季节
    NEXT_SEASON = {
        autumn = "winter",
        winter = "spring",
        spring = "summer",
        summer = "autumn",
    },

    -- 巨鹿袭击计时器名（worldsettingstimer）
    DEERCLOPS_TIMER = "deerclops_timetoattack",

    -- 熊獾袭击计时器名（worldsettingstimer）
    BEARGER_TIMER = "bearger_timetospawn",
}
