--- dst-broadcasts：可扩展的全服公告框架。
--- 新增模块：在 scripts/features/ 下添加（玩家数值见 features/stats/），并在此 modimport。

GLOBAL.setmetatable(env, { __index = function(_, k) return GLOBAL.rawget(GLOBAL, k) end })

modimport("scripts/core.lua")
modimport("scripts/i18n.lua")

AddPrefabPostInit("world", function(inst)
  if inst.ismastersim then
    --- 加载自定义组件
    inst:AddComponent("state_3774915634")
  end
end)

modimport("scripts/features/weather.lua")
modimport("scripts/features/broke.lua")
modimport("scripts/features/fueled.lua")
modimport("scripts/features/stats/hunger.lua")
modimport("scripts/features/stats/sanity.lua")
modimport("scripts/features/stats/health.lua")
modimport("scripts/features/stats/temperature.lua")
modimport("scripts/features/stats/moisture.lua")
modimport("scripts/features/stats/krampus.lua")
modimport("scripts/features/stats/lucky.lua")
modimport("scripts/features/warning_common.lua")
modimport("scripts/features/hounded.lua")
modimport("scripts/features/warning.lua")

modimport("scripts/features/frograin.lua")
modimport("scripts/features/calendar.lua")
modimport("scripts/features/harvest.lua")
modimport("scripts/features/wx78.lua")
modimport("scripts/features/pearl.lua")
modimport("scripts/features/appear.lua")
modimport("scripts/features/defeat.lua")
modimport("scripts/features/cave.lua")
modimport("scripts/features/radio.lua")
