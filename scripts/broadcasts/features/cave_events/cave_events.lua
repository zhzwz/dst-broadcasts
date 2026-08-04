--[[
  洞穴事件：噩梦相位、酸雨、遗迹重置、地震预警。
  仅洞穴主机；读档首帧不播。
]]

local S = BROADCASTS_STRINGS

local function OnNightmarePhase(_, phase)
  local message = S.nightmare_phases[phase]
  if message ~= nil then
    mod.Announce(message)
  end
end

local function OnAcidRain(_, is_raining)
  mod.Announce(is_raining and S.acid_rain_started or S.acid_rain_ended)
end

AddSimPostInit(mod.Wrap("cave_events_init", function()
  if not mod.World.IsMaster() or not mod.World.IsCave() then
    return
  end

  -- 读档还原世界状态时可能同步触发 WatchWorldState；首帧后再接受变化
  local ready = false
  TheWorld:DoTaskInTime(0, function()
    ready = true
  end)

  TheWorld:WatchWorldState("nightmarephase", mod.Wrap("cave_nightmare", function(_, phase)
    if ready then
      OnNightmarePhase(_, phase)
    end
  end))
  TheWorld:WatchWorldState("isacidraining", mod.Wrap("cave_acidrain", function(_, is_raining)
    if ready then
      OnAcidRain(_, is_raining)
    end
  end))
  TheWorld:ListenForEvent("resetruins", mod.Wrap("cave_ruins", function()
    mod.Announce(S.ruins_reset)
  end))

  if TheWorld.net ~= nil and TheWorld.net.components.quaker ~= nil then
    TheWorld.net:ListenForEvent("warnquake", mod.Wrap("cave_quake", function()
      mod.Announce(S.quake_warning)
    end))
  end
end))
