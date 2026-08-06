--- dst-broadcasts：可扩展的全服播报框架。
--- 新增模块：在 scripts/broadcasts/ 下添加，并在此 modimport。

GLOBAL.setmetatable(env, { __index = function(_, k) return GLOBAL.rawget(GLOBAL, k) end })

modimport("scripts/broadcasts/i18n.lua")
modimport("scripts/broadcasts/mod.lua")

AddPrefabPostInit("world", function(inst)
  if inst.ismastersim then
    --- 自定义组件
    inst:AddComponent("state_3774915634")
  end
end)

modimport("scripts/broadcasts/features/item_status/init.lua")
modimport("scripts/broadcasts/features/player_vitals/init.lua")
modimport("scripts/broadcasts/features/attack_warning/init.lua")
modimport("scripts/broadcasts/features/frog_rain/init.lua")
modimport("scripts/broadcasts/features/calendar/init.lua")
modimport("scripts/broadcasts/features/weather.lua")
modimport("scripts/broadcasts/features/harvest/init.lua")
modimport("scripts/broadcasts/features/portable_storage/init.lua")
modimport("scripts/broadcasts/features/pearl/init.lua")
modimport("scripts/broadcasts/features/appear/init.lua")
modimport("scripts/broadcasts/features/boss_defeat/init.lua")
modimport("scripts/broadcasts/features/cave_events/init.lua")
modimport("scripts/broadcasts/features/morning_radio/init.lua")
modimport("scripts/broadcasts/features/dusk_radio/init.lua")
modimport("scripts/broadcasts/features/midnight_radio/init.lua")
