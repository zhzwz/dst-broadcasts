--[[
  巨鹿 / 熊獾：倒计时预警（现身见 features/appear）。
]]

local C = BROADCASTS_ATTACK_WARNING

local DEERCLOPS_ENABLED = GetModConfigData("deerclops_warning_enabled")
local BEARGER_ENABLED = GetModConfigData("bearger_warning_enabled")

local BOSSES = {}
if DEERCLOPS_ENABLED then
  BOSSES[#BOSSES + 1] = {
    name = BROADCASTS_STRINGS.bosses.deerclops,
    timer = C.DEERCLOPS_TIMER,
  }
end
if BEARGER_ENABLED then
  BOSSES[#BOSSES + 1] = {
    name = BROADCASTS_STRINGS.bosses.bearger,
    timer = C.BEARGER_TIMER,
  }
end

if #BOSSES == 0 then
  return
end

AddSimPostInit(mod.Wrap("hassler_init", function()
  if not TheWorld.ismastersim then
    return
  end
  if TheWorld:HasTag("cave") then
    return
  end
  if TheWorld.components.worldsettingstimer == nil then
    return
  end

  for _, boss in ipairs(BOSSES) do
    local timer = boss.timer
    local name = boss.name
    BROADCASTS_WATCH_ATTACK_WARNING(function()
      local wst = TheWorld.components.worldsettingstimer
      if wst == nil or not wst:ActiveTimerExists(timer) then
        return nil
      end
      if wst:IsPaused(timer) then
        return false
      end
      return wst:GetTimeLeft(timer)
    end, function()
      return name
    end)
  end
end))
