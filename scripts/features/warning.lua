--- 巨鹿 / 熊獾袭击预警（仅森林）。
--- 倒计时多档；现身见 appear.lua。

AddSimPostInit(core.Wrap(function()
  if not core.World.IsServerSide() then return end
  if not core.World.IsForest() then return end
  --- 巨鹿
  core.WatchWorldSettingsTimer("deerclops", "deerclops_timetoattack")
  --- 熊獾
  core.WatchWorldSettingsTimer("bearger", "bearger_timetospawn")
end))
