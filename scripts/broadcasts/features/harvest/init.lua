--[[
  收获入口：大理石灌木、蜂箱、农田、晾晒架。
  细项开关在此判断；modmain 只需 modimport 本文件。
]]

local marbleshrub = GetModConfigData("harvest_marbleshrub_enabled")
local beebox = GetModConfigData("harvest_beebox_enabled")
local farmland = GetModConfigData("harvest_farmland_enabled")
local dryingrack = GetModConfigData("harvest_dryingrack_enabled")

if not (marbleshrub or beebox or farmland or dryingrack) then
  return
end

BROADCASTS_HARVEST = {
  MARBLESHRUB = marbleshrub == true,
  BEEBOX = beebox == true,
  FARMLAND = farmland == true,
  DRYINGRACK = dryingrack == true,
}

modimport("scripts/broadcasts/features/harvest/harvest.lua")
