local FILES = {
  zh = "scripts/broadcasts/i18n/zh.lua",
  zhr = "scripts/broadcasts/i18n/zh.lua",
  zht = "scripts/broadcasts/i18n/zht.lua",
  en = "scripts/broadcasts/i18n/en.lua",
  fr = "scripts/broadcasts/i18n/fr.lua",
  de = "scripts/broadcasts/i18n/de.lua",
  it = "scripts/broadcasts/i18n/it.lua",
  es = "scripts/broadcasts/i18n/es.lua",
  pt = "scripts/broadcasts/i18n/pt.lua",
  pl = "scripts/broadcasts/i18n/pl.lua",
  ru = "scripts/broadcasts/i18n/ru.lua",
  ko = "scripts/broadcasts/i18n/ko.lua",
  ja = "scripts/broadcasts/i18n/ja.lua",
}

local language = GetModConfigData("language")

modimport(FILES[language] or FILES.zh)
