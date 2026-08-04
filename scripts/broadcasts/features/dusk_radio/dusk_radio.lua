--[[
  黄昏电台：白天进入黄昏时开播。
  节目内容待填。
]]

modimport("scripts/broadcasts/lib/day_slot.lua")

local Slot = BROADCASTS_DAY_SLOT

local function OnAir()
  -- TODO: 黄昏电台节目
end

AddSimPostInit(mod.Wrap("dusk_radio_init", function()
  if not mod.World.IsMaster() then
    return
  end

  local key = Slot.PhaseStateKey(mod.World.IsCave())
  local prev_phase = TheWorld.state ~= nil and TheWorld.state[key] or nil
  TheWorld:WatchWorldState(key, mod.Wrap("dusk_radio_phase", function(_, phase)
    local previous = prev_phase
    prev_phase = phase
    if not Slot.IsPhaseTransition(previous, phase, "day", "dusk") then
      return
    end
    TheWorld:DoTaskInTime(0, mod.Wrap("dusk_radio_onair", OnAir))
  end))
end))
