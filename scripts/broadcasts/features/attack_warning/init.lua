--- 袭击预警入口：猎犬、洞穴蠕虫、巨鹿、熊獾。
--- 细项开关在此判断；modmain 只需 modimport 本文件。

local hounds = GetModConfigData("hounds_warning_enabled")
local worms = GetModConfigData("depths_worms_warning_enabled")
local deerclops = GetModConfigData("deerclops_warning_enabled")
local bearger = GetModConfigData("bearger_warning_enabled")

if not (hounds or worms or deerclops or bearger) then
  return
end

modimport("scripts/broadcasts/lib/cross_real_thresholds.lua")
modimport("scripts/broadcasts/features/attack_warning/constants.lua")
modimport("scripts/broadcasts/features/attack_warning/watch.lua")

if hounds or worms then
  modimport("scripts/broadcasts/features/attack_warning/hounded.lua")
end

if deerclops or bearger then
  modimport("scripts/broadcasts/features/attack_warning/hassler.lua")
end
