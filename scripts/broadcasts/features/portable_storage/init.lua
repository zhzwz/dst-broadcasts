--- 便携储存单元入口。
--- 开关在此判断；modmain 只需 modimport 本文件。

if not GetModConfigData("portable_storage_enabled") then
  return
end

modimport("scripts/broadcasts/features/portable_storage/portable_storage.lua")
