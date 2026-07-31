name = "Broadcasts"
description = [[
纯服务端全服播报工具，客户端无需安装。

- 猎犬、蠕虫、巨鹿与熊獾袭击预警
- 物品低耐久、低燃料与损毁提醒
- 每日巨兽简报与击败播报
]]
author = "zhzwz"
version = "1.1.0"

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
    "broadcasts",
}

configuration_options = {
    {
        name = "usage_break_enabled",
        label = "物品状态提醒",
        hover = "播报玩家持有物品的低耐久、低燃料与损毁状态。",
        options = {
            { description = "启用", data = true },
            { description = "禁用", data = false },
        },
        default = true,
    },
    {
        name = "hounded_enabled",
        label = "猎犬与蠕虫预警",
        hover = "在来袭前 1 个游戏日及多个现实时间节点提醒。",
        options = {
            { description = "启用", data = true },
            { description = "禁用", data = false },
        },
        default = true,
    },
    {
        name = "hassler_boss_enabled",
        label = "巨鹿与熊獾预警",
        hover = "在来袭前分阶段提醒，并在巨兽现身时立即播报。",
        options = {
            { description = "启用", data = true },
            { description = "禁用", data = false },
        },
        default = true,
    },
    {
        name = "static_boss_enabled",
        label = "每日巨兽简报",
        hover = "每天开始时汇总当前分片仍然存活的巨兽。",
        options = {
            { description = "启用", data = true },
            { description = "禁用", data = false },
        },
        default = true,
    },
    {
        name = "boss_defeat_enabled",
        label = "巨兽击败播报",
        hover = "巨兽被击败时通知当前分片的所有玩家。",
        options = {
            { description = "启用", data = true },
            { description = "禁用", data = false },
        },
        default = true,
    },
}
