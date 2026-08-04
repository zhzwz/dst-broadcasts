--[[
  青蛙雨统计入口。
  开关在此判断；关闭时仍清理未结算计数，避免再次开启后误播。
  modmain 只需 modimport 本文件。
]]

local enabled = GetModConfigData("frog_rain_enabled")

modimport("scripts/broadcasts/features/frog_rain/constants.lua")

if not enabled then
  local C = BROADCASTS_FROG_RAIN
  AddSimPostInit(mod.Wrap("frog_rain_clear", function()
    if not TheWorld.ismastersim or TheWorld:HasTag("cave") then
      return
    end
    local state = TheWorld.components.state_3774915634
    if state == nil then
      return
    end
    state:Set(C.ACTIVE_KEY, nil)
    state:Set(C.COUNT_KEY, nil)
    state:Set(C.LUNAR_COUNT_KEY, nil)
  end))
  return
end

modimport("scripts/broadcasts/features/frog_rain/frog_rain.lua")
