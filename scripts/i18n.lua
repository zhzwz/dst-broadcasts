local FILES = {
  zh = "scripts/i18n/zh.lua",
  zhr = "scripts/i18n/zh.lua",
  zht = "scripts/i18n/zht.lua",
  en = "scripts/i18n/en.lua",
  fr = "scripts/i18n/fr.lua",
  de = "scripts/i18n/de.lua",
  it = "scripts/i18n/it.lua",
  es = "scripts/i18n/es.lua",
  pt = "scripts/i18n/pt.lua",
  pl = "scripts/i18n/pl.lua",
  ru = "scripts/i18n/ru.lua",
  ko = "scripts/i18n/ko.lua",
  ja = "scripts/i18n/ja.lua",
}

local language = GetModConfigData("language")

modimport(FILES[language] or FILES.zh)
