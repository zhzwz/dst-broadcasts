--- 模组元数据与配置项。界面文案：modinfo/language/*.lua
--- DST modinfo 沙箱不能加载外部文件；bun run build-modinfo 会生成根目录 modinfo.lua
--- BEGIN_MODINFO_LANGUAGES
--- name/description 等是写入 modinfo 环境的约定全局，不是漏写 local
---@diagnostic disable: lowercase-global
---@class BroadcastsModinfoLang
---@field description string
---@field language_label string
---@field language_hover string

---@type BroadcastsModinfoLang
local L = {
  description = "",
  language_label = "",
  language_hover = "",
}
--- END_MODINFO_LANGUAGES
name = "Broadcasts"
description = L.description
author = "zhzwz"
version = "1.8.2"

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
}
