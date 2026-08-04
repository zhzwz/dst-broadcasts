--[[
  早间电台：每个游戏日开始（cycles +1）时开播。
  节目内容待填。
]]

modimport("scripts/broadcasts/lib/day_slot.lua")

local Slot = BROADCASTS_DAY_SLOT

local function OnAir()
  -- TODO: 早间电台节目
end

AddSimPostInit(mod.Wrap("morning_radio_init", function()
  if not mod.World.IsMaster() then
    return
  end

  local prev_cycles = TheWorld.state.cycles
  TheWorld:WatchWorldState("cycles", mod.Wrap("morning_radio_cycles", function(_, cycles)
    local previous = prev_cycles
    prev_cycles = cycles
    if not Slot.IsCyclesIncrement(previous, cycles) then
      return
    end
    TheWorld:DoTaskInTime(0, mod.Wrap("morning_radio_onair", OnAir))
  end))
end))
