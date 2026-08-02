--[[
  按模组配置加载对应语言文案，对外只暴露 BROADCASTS_STRINGS。
]]

local LANGUAGE_FILES = {
    zh = "scripts/broadcasts/language/zh.lua",
    zhr = "scripts/broadcasts/language/zh.lua",
    zht = "scripts/broadcasts/language/zht.lua",
    en = "scripts/broadcasts/language/en.lua",
    fr = "scripts/broadcasts/language/fr.lua",
    de = "scripts/broadcasts/language/de.lua",
    it = "scripts/broadcasts/language/it.lua",
    es = "scripts/broadcasts/language/es.lua",
    pt = "scripts/broadcasts/language/pt.lua",
    pl = "scripts/broadcasts/language/pl.lua",
    ru = "scripts/broadcasts/language/ru.lua",
    ko = "scripts/broadcasts/language/ko.lua",
    ja = "scripts/broadcasts/language/ja.lua",
}

local language = GetModConfigData("language")
modimport(LANGUAGE_FILES[language] or LANGUAGE_FILES.zh)
