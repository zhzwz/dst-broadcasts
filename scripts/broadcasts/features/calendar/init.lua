--- 日历入口。
--- 开关在此判断；modmain 只需 modimport 本文件。

if not GetModConfigData("calendar_enabled") then
  return
end

modimport("scripts/broadcasts/features/calendar/calendar.lua")
