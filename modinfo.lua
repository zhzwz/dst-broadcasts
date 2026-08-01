local EN = {
    description = [[
Server-side broadcast utility. No client installation required.

- Hound, worm, Deerclops, and Bearger warnings
- Cave event warnings and status announcements
- Frog rain totals when each shower ends
- Low durability, low fuel, and item break alerts
- Hunger and sanity alerts at 10 and 0
- Daily season, weather, event, and boss reports
- Boss appearance and defeat announcements
]],
    language_label = "Broadcast language",
    language_hover = "Select the language used for server announcements.",
    item_label = "Item status alerts",
    item_hover = "Announce low durability, low fuel, and broken items held by players.",
    vitals_label = "Hunger and sanity alerts",
    vitals_hover = "Announce once when hunger or sanity drops to 10, and again at 0.",
    hounded_label = "Hound and worm warnings",
    hounded_hover = "Warn at multiple intervals before an attack.",
    cave_events_label = "Cave event alerts",
    cave_events_hover = "Announce nightmare cycles, earthquakes, acid rain, and Ruins resets.",
    frog_rain_label = "Frog rain reports",
    frog_rain_hover = "Count frogs spawned by each frog rain and report the total when it ends.",
    hassler_label = "Deerclops and Bearger warnings",
    hassler_hover = "Warn before an attack and announce when the boss appears.",
    morning_label = "The Constant Daily",
    morning_hover = "Report the season, weather outlook, upcoming events, and living bosses each morning.",
    defeat_label = "Boss defeat announcements",
    defeat_hover = "Notify all players in the current shard when a boss is defeated.",
    debug_label = "Debug logging",
    debug_hover = "When enabled, Broadcasts errors are also announced in-game.",
    enabled = "Enabled",
    disabled = "Disabled",
}

local ZH = {
    description = [[
纯服务端全服播报工具，客户端无需安装。

- 猎犬、蠕虫、巨鹿与熊獾袭击预警
- 洞穴事件预警与状态播报
- 青蛙雨结束时播报本次青蛙总数
- 物品低耐久、低燃料与损毁播报
- 玩家饱食度或理智降至 10 / 0 时播报
- 每日季节、天气、事件与存活巨兽早报
- 巨兽现身与击败播报
]],
    language_label = "播报语言",
    language_hover = "选择服务器播报使用的语言。",
    item_label = "物品状态播报",
    item_hover = "播报玩家持有物品的低耐久、低燃料与损毁状态。",
    vitals_label = "饱食度与理智播报",
    vitals_hover = "饱食度或理智降至 10 时播报一次，降至 0 时再播报一次。",
    hounded_label = "猎犬与蠕虫预警",
    hounded_hover = "在来袭前的多个时间节点播报。",
    cave_events_label = "洞穴事件播报",
    cave_events_hover = "播报噩梦循环、地震、酸雨与远古遗迹重置。",
    frog_rain_label = "青蛙雨统计",
    frog_rain_hover = "统计每次青蛙雨生成的青蛙，并在结束时播报总数。",
    hassler_label = "巨鹿与熊獾预警",
    hassler_hover = "在来袭前分阶段播报，并在巨兽现身时立即播报。",
    morning_label = "永恒早报",
    morning_hover = "每天开始时播报季节、天气趋势、近期事件与存活巨兽。",
    defeat_label = "巨兽击败播报",
    defeat_hover = "巨兽被击败时向当前分片的所有玩家播报。",
    debug_label = "调试模式",
    debug_hover = "开启后，Broadcasts 报错会同时出现在游戏播报中。",
    enabled = "启用",
    disabled = "禁用",
}

local L = ChooseTranslationTable({
    EN,
    zh = ZH,
    zhr = ZH,
    zht = ZH,
})

name = "Broadcasts"
description = L.description
author = "zhzwz"
version = "1.2.2"

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
        name = "language",
        label = L.language_label,
        hover = L.language_hover,
        options = {
            { description = "简体中文", data = "zh" },
            { description = "English", data = "en" },
        },
        default = "zh",
    },
    {
        name = "usage_break_enabled",
        label = L.item_label,
        hover = L.item_hover,
        options = {
            { description = L.enabled, data = true },
            { description = L.disabled, data = false },
        },
        default = true,
    },
    {
        name = "player_vitals_enabled",
        label = L.vitals_label,
        hover = L.vitals_hover,
        options = {
            { description = L.enabled, data = true },
            { description = L.disabled, data = false },
        },
        default = true,
    },
    {
        name = "hounded_enabled",
        label = L.hounded_label,
        hover = L.hounded_hover,
        options = {
            { description = L.enabled, data = true },
            { description = L.disabled, data = false },
        },
        default = true,
    },
    {
        name = "cave_events_enabled",
        label = L.cave_events_label,
        hover = L.cave_events_hover,
        options = {
            { description = L.enabled, data = true },
            { description = L.disabled, data = false },
        },
        default = true,
    },
    {
        name = "frog_rain_enabled",
        label = L.frog_rain_label,
        hover = L.frog_rain_hover,
        options = {
            { description = L.enabled, data = true },
            { description = L.disabled, data = false },
        },
        default = true,
    },
    {
        name = "hassler_boss_enabled",
        label = L.hassler_label,
        hover = L.hassler_hover,
        options = {
            { description = L.enabled, data = true },
            { description = L.disabled, data = false },
        },
        default = true,
    },
    {
        name = "morning_news_enabled",
        label = L.morning_label,
        hover = L.morning_hover,
        options = {
            { description = L.enabled, data = true },
            { description = L.disabled, data = false },
        },
        default = true,
    },
    {
        name = "boss_defeat_enabled",
        label = L.defeat_label,
        hover = L.defeat_hover,
        options = {
            { description = L.enabled, data = true },
            { description = L.disabled, data = false },
        },
        default = true,
    },
    {
        name = "debug_enabled",
        label = L.debug_label,
        hover = L.debug_hover,
        options = {
            { description = L.enabled, data = true },
            { description = L.disabled, data = false },
        },
        default = false,
    },
}
