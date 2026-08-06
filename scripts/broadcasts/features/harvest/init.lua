--- 收获入口：大理石灌木、蜂箱、农田、晾晒架。
--- 永久开启；modmain 只需 modimport 本文件。

BROADCASTS_HARVEST = {
  MARBLESHRUB = true,
  BEEBOX = true,
  FARMLAND = true,
  DRYINGRACK = true,
}

modimport("scripts/broadcasts/features/harvest/harvest.lua")
