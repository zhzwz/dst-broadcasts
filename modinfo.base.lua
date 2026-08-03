-- 模组元数据与配置项。界面文案唯一来源：modinfo_language/*.lua
-- DST 的 modinfo 沙箱只有 folder_name / locale / ChooseTranslationTable，不能加载外部文件；
-- 打包或本地测试前运行 bun run embed-modinfo，由工具把文案内联进生成的 modinfo.lua。
-- BEGIN_MODINFO_LANGUAGES
local L = nil -- placeholder; replaced by embed-modinfo
-- END_MODINFO_LANGUAGES
name = "Broadcasts"
description = L.description
author = "zhzwz"
version = "1.5.3"

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
            { description = "Français", data = "fr" },
            { description = "Español", data = "es" },
            { description = "Deutsch", data = "de" },
            { description = "Italiano", data = "it" },
            { description = "Português", data = "pt" },
            { description = "Polski", data = "pl" },
            { description = "Русский", data = "ru" },
            { description = "한국어", data = "ko" },
            { description = "繁體中文", data = "zht" },
            { description = "日本語", data = "ja" },
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
        name = "pearl_status_enabled",
        label = L.pearl_label,
        hover = L.pearl_hover,
        options = {
            { description = L.enabled, data = true },
            { description = L.disabled, data = false },
        },
        default = true,
    },
    {
        name = "drone_delivery_enabled",
        label = L.drone_label,
        hover = L.drone_hover,
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
