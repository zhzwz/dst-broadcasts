-- 模组元数据与配置项。界面文案：modinfo/language/*.lua
-- DST modinfo 沙箱不能加载外部文件；bun run build-modinfo 会生成根目录 modinfo.lua
-- BEGIN_MODINFO_LANGUAGES
-- name/description 等是写入 modinfo 环境的约定全局，不是漏写 local
---@diagnostic disable: lowercase-global
---@class BroadcastsModinfoLang
---@field description string
---@field language_label string
---@field language_hover string
---@field item_durability_label string
---@field item_durability_hover string
---@field item_fuel_label string
---@field item_fuel_hover string
---@field item_break_label string
---@field item_break_hover string
---@field item_break_warning_label string
---@field item_break_warning_hover string
---@field hunger_label string
---@field hunger_hover string
---@field sanity_label string
---@field sanity_hover string
---@field health_label string
---@field health_hover string
---@field temperature_label string
---@field temperature_hover string
---@field moisture_label string
---@field moisture_hover string
---@field hounds_label string
---@field hounds_hover string
---@field depths_worms_label string
---@field depths_worms_hover string
---@field deerclops_label string
---@field deerclops_hover string
---@field bearger_label string
---@field bearger_hover string
---@field frog_rain_label string
---@field frog_rain_hover string
---@field calendar_label string
---@field calendar_hover string
---@field harvest_marbleshrub_label string
---@field harvest_marbleshrub_hover string
---@field harvest_beebox_label string
---@field harvest_beebox_hover string
---@field harvest_farmland_label string
---@field harvest_farmland_hover string
---@field harvest_dryingrack_label string
---@field harvest_dryingrack_hover string
---@field portable_storage_label string
---@field portable_storage_hover string
---@field enabled string
---@field disabled string

---@type BroadcastsModinfoLang
local L = {
  description = "",
  language_label = "",
  language_hover = "",
  item_durability_label = "",
  item_durability_hover = "",
  item_fuel_label = "",
  item_fuel_hover = "",
  item_break_label = "",
  item_break_hover = "",
  item_break_warning_label = "",
  item_break_warning_hover = "",
  hunger_label = "",
  hunger_hover = "",
  sanity_label = "",
  sanity_hover = "",
  health_label = "",
  health_hover = "",
  temperature_label = "",
  temperature_hover = "",
  moisture_label = "",
  moisture_hover = "",
  hounds_label = "",
  hounds_hover = "",
  depths_worms_label = "",
  depths_worms_hover = "",
  deerclops_label = "",
  deerclops_hover = "",
  bearger_label = "",
  bearger_hover = "",
  frog_rain_label = "",
  frog_rain_hover = "",
  calendar_label = "",
  calendar_hover = "",
  harvest_marbleshrub_label = "",
  harvest_marbleshrub_hover = "",
  harvest_beebox_label = "",
  harvest_beebox_hover = "",
  harvest_farmland_label = "",
  harvest_farmland_hover = "",
  harvest_dryingrack_label = "",
  harvest_dryingrack_hover = "",
  portable_storage_label = "",
  portable_storage_hover = "",
  enabled = "",
  disabled = "",
}
-- END_MODINFO_LANGUAGES
name = "Broadcasts"
description = L.description
author = "zhzwz"
version = "1.8.1"

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
    name = "item_durability_enabled",
    label = L.item_durability_label,
    hover = L.item_durability_hover,
    options = {
      { description = L.enabled,  data = true },
      { description = L.disabled, data = false },
    },
    default = true,
  },
  {
    name = "item_fuel_enabled",
    label = L.item_fuel_label,
    hover = L.item_fuel_hover,
    options = {
      { description = L.enabled,  data = true },
      { description = L.disabled, data = false },
    },
    default = true,
  },
  {
    name = "item_break_enabled",
    label = L.item_break_label,
    hover = L.item_break_hover,
    options = {
      { description = L.enabled,  data = true },
      { description = L.disabled, data = false },
    },
    default = true,
  },
  {
    name = "item_break_warning_enabled",
    label = L.item_break_warning_label,
    hover = L.item_break_warning_hover,
    options = {
      { description = L.enabled,  data = true },
      { description = L.disabled, data = false },
    },
    default = true,
  },
  {
    name = "player_hunger_enabled",
    label = L.hunger_label,
    hover = L.hunger_hover,
    options = {
      { description = L.enabled,  data = true },
      { description = L.disabled, data = false },
    },
    default = true,
  },
  {
    name = "player_sanity_enabled",
    label = L.sanity_label,
    hover = L.sanity_hover,
    options = {
      { description = L.enabled,  data = true },
      { description = L.disabled, data = false },
    },
    default = true,
  },
  {
    name = "player_health_enabled",
    label = L.health_label,
    hover = L.health_hover,
    options = {
      { description = L.enabled,  data = true },
      { description = L.disabled, data = false },
    },
    default = true,
  },
  {
    name = "player_temperature_enabled",
    label = L.temperature_label,
    hover = L.temperature_hover,
    options = {
      { description = L.enabled,  data = true },
      { description = L.disabled, data = false },
    },
    default = true,
  },
  {
    name = "player_moisture_enabled",
    label = L.moisture_label,
    hover = L.moisture_hover,
    options = {
      { description = L.enabled,  data = true },
      { description = L.disabled, data = false },
    },
    default = true,
  },
  {
    name = "hounds_warning_enabled",
    label = L.hounds_label,
    hover = L.hounds_hover,
    options = {
      { description = L.enabled,  data = true },
      { description = L.disabled, data = false },
    },
    default = true,
  },
  {
    name = "depths_worms_warning_enabled",
    label = L.depths_worms_label,
    hover = L.depths_worms_hover,
    options = {
      { description = L.enabled,  data = true },
      { description = L.disabled, data = false },
    },
    default = true,
  },
  {
    name = "deerclops_warning_enabled",
    label = L.deerclops_label,
    hover = L.deerclops_hover,
    options = {
      { description = L.enabled,  data = true },
      { description = L.disabled, data = false },
    },
    default = true,
  },
  {
    name = "bearger_warning_enabled",
    label = L.bearger_label,
    hover = L.bearger_hover,
    options = {
      { description = L.enabled,  data = true },
      { description = L.disabled, data = false },
    },
    default = true,
  },
  {
    name = "frog_rain_enabled",
    label = L.frog_rain_label,
    hover = L.frog_rain_hover,
    options = {
      { description = L.enabled,  data = true },
      { description = L.disabled, data = false },
    },
    default = true,
  },
  {
    name = "calendar_enabled",
    label = L.calendar_label,
    hover = L.calendar_hover,
    options = {
      { description = L.enabled,  data = true },
      { description = L.disabled, data = false },
    },
    default = true,
  },
  {
    name = "harvest_marbleshrub_enabled",
    label = L.harvest_marbleshrub_label,
    hover = L.harvest_marbleshrub_hover,
    options = {
      { description = L.enabled,  data = true },
      { description = L.disabled, data = false },
    },
    default = true,
  },
  {
    name = "harvest_beebox_enabled",
    label = L.harvest_beebox_label,
    hover = L.harvest_beebox_hover,
    options = {
      { description = L.enabled,  data = true },
      { description = L.disabled, data = false },
    },
    default = true,
  },
  {
    name = "harvest_farmland_enabled",
    label = L.harvest_farmland_label,
    hover = L.harvest_farmland_hover,
    options = {
      { description = L.enabled,  data = true },
      { description = L.disabled, data = false },
    },
    default = true,
  },
  {
    name = "harvest_dryingrack_enabled",
    label = L.harvest_dryingrack_label,
    hover = L.harvest_dryingrack_hover,
    options = {
      { description = L.enabled,  data = true },
      { description = L.disabled, data = false },
    },
    default = true,
  },
  {
    name = "portable_storage_enabled",
    label = L.portable_storage_label,
    hover = L.portable_storage_hover,
    options = {
      { description = L.enabled,  data = true },
      { description = L.disabled, data = false },
    },
    default = true,
  },
}
