--[[
  午夜电台：黄昏进入黑夜时开播。
  节目内容待填。
]]

modimport("scripts/broadcasts/lib/day_slot.lua")

local Safe = BROADCASTS_SAFE
local Slot = BROADCASTS_DAY_SLOT

local function OnAir()
  -- TODO: 午夜电台节目
end

AddSimPostInit(Safe.Wrap("midnight_radio_init", function()
  if not TheWorld.ismastersim then
    return
  end

  local key = Slot.PhaseStateKey(TheWorld:HasTag("cave"))
  local prev_phase = TheWorld.state ~= nil and TheWorld.state[key] or nil
  TheWorld:WatchWorldState(key, Safe.Wrap("midnight_radio_phase", function(_, phase)
    local previous = prev_phase
    prev_phase = phase
    if not Slot.IsPhaseTransition(previous, phase, "dusk", "night") then
      return
    end
    TheWorld:DoTaskInTime(0, Safe.Wrap("midnight_radio_onair", OnAir))
  end))
end))
