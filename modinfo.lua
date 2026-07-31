name = "DST Warnings"
description = [[
全服预警合集。

- 猎犬/蠕虫、巨鹿/熊獾袭击倒计时
- 可缝补 / 可补燃料低耐久提醒
- 武器、护甲损坏提醒
- 巨兽存活日报
]]
author = "zhzwz"
version = "0.7.0"

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
        label = "物品耐久/损坏预警",
        hover = "可缝补、可补燃料低耐久；武器/护甲损坏时提醒",
        options = {
            { description = "开启", data = true },
            { description = "关闭", data = false },
        },
        default = true,
    },
    {
        name = "hounded_enabled",
        label = "猎犬/蠕虫袭击预警",
        hover = "提前 1 天 + 现实时间 5分/2分/1分/30秒/10秒/5秒",
        options = {
            { description = "开启", data = true },
            { description = "关闭", data = false },
        },
        default = true,
    },
    {
        name = "hassler_boss_enabled",
        label = "巨鹿/熊獾袭击预警",
        hover = "提前 1 天 + 现实时间 5分/2分/1分/30秒/10秒/5秒；现身时提示",
        options = {
            { description = "开启", data = true },
            { description = "关闭", data = false },
        },
        default = true,
    },
    {
        name = "static_boss_enabled",
        label = "巨兽存活播报",
        hover = "每天刷新时扫描龙蝇、蜂王等，若已在世界中则提示",
        options = {
            { description = "开启", data = true },
            { description = "关闭", data = false },
        },
        default = true,
    },
}
