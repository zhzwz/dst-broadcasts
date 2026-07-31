name = "DST Warnings"
description = [[
全服预警合集。

- 可缝补装备（眼球伞、雨衣等）低耐久提示
- 猎犬 / 洞穴蠕虫袭击倒计时提示
]]
author = "zhzwz"
version = "0.2.0"

forumthread = ""

api_version = 10
priority = 0

dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false
shipwrecked_compatible = false

client_only_mod = false
all_clients_require_mod = false

server_filter_tags = {
    "utility",
    "warnings",
}

configuration_options = {
    {
        name = "usage_break_enabled",
        label = "可缝补装备耐久预警",
        hover = "眼球伞、雨衣等 USAGE 耐久低于阈值时全服提示",
        options = {
            { description = "开启", data = true },
            { description = "关闭", data = false },
        },
        default = true,
    },
    {
        name = "usage_break_percent",
        label = "耐久预警阈值",
        hover = "剩余耐久低于该百分比时提醒（缝补回升后可再次提醒）",
        options = {
            { description = "5%", data = 5 },
            { description = "10%", data = 10 },
            { description = "20%", data = 20 },
            { description = "30%", data = 30 },
            { description = "50%", data = 50 },
        },
        default = 20,
    },
    {
        name = "hounded_enabled",
        label = "猎犬/蠕虫袭击预警",
        hover = "地表猎犬、洞穴蠕虫等 hounded 袭击倒计时全服提示",
        options = {
            { description = "开启", data = true },
            { description = "关闭", data = false },
        },
        default = true,
    },
    {
        name = "hounded_advance_days",
        label = "提前几天播报",
        hover = "袭击尚未进入警戒阶段时，按天数提前提示（0=只在警戒/临近时提示）",
        options = {
            { description = "关闭", data = 0 },
            { description = "1 天", data = 1 },
            { description = "2 天", data = 2 },
            { description = "3 天", data = 3 },
        },
        default = 1,
    },
    {
        name = "hounded_urgent_sec",
        label = "临近二次提醒",
        hover = "警戒阶段中，剩余时间低于该秒数时再提醒一次",
        options = {
            { description = "15 秒", data = 15 },
            { description = "30 秒", data = 30 },
            { description = "60 秒", data = 60 },
            { description = "关闭", data = 0 },
        },
        default = 30,
    },
}
