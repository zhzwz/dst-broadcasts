local L = ChooseTranslationTable({
    require("modinfo_language/en"),
    zh = require("modinfo_language/zh"),
    zhr = require("modinfo_language/zh"),
    zht = require("modinfo_language/zht"),
    fr = require("modinfo_language/fr"),
    de = require("modinfo_language/de"),
    it = require("modinfo_language/it"),
    es = require("modinfo_language/es"),
    pt = require("modinfo_language/pt"),
    pl = require("modinfo_language/pl"),
    ru = require("modinfo_language/ru"),
    ko = require("modinfo_language/ko"),
    ja = require("modinfo_language/ja"),
})
name = "Broadcasts"
description = L.description
author = "zhzwz"
version = "1.3.0"

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
            { description = "繁體中文", data = "zht" },
            { description = "English", data = "en" },
            { description = "Français", data = "fr" },
            { description = "Deutsch", data = "de" },
            { description = "Italiano", data = "it" },
            { description = "Español", data = "es" },
            { description = "Português", data = "pt" },
            { description = "Polski", data = "pl" },
            { description = "Русский", data = "ru" },
            { description = "한국어", data = "ko" },
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
