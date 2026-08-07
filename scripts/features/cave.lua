--- 洞穴事件：噩梦相位、酸雨起止、远古遗迹重置、地震预警。
--- 仅洞穴主机；读档首帧不播（SetTimeout(0) 后再响应 WatchWorldState）。

local S = i18n

local function OnNightmarePhase(_, phase)
  local message = S.nightmare_phases[phase]
  if message ~= nil then
    core.Announce(message)
  end
end

local function OnAcidRain(_, is_raining)
  core.Announce(is_raining and S.acid_rain_started or S.acid_rain_ended)
end

AddSimPostInit(core.Wrap(function()
  if not core.IsServer() or not core.IsCaveWorld() then
    return
  end

  --- 读档还原世界状态时可能同步触发 WatchWorldState；首帧后再接受变化
  local ready = false
  core.SetTimeout(TheWorld, function()
    ready = true
  end, 0)

  TheWorld:WatchWorldState("nightmarephase", core.Wrap(function(_, phase)
    if ready then
      OnNightmarePhase(_, phase)
    end
  end))
  TheWorld:WatchWorldState("isacidraining", core.Wrap(function(_, is_raining)
    if ready then
      OnAcidRain(_, is_raining)
    end
  end))
  TheWorld:ListenForEvent("resetruins", core.Wrap(function()
    core.Announce(S.ruins_reset)
  end))

  if TheWorld.net ~= nil and TheWorld.net.components.quaker ~= nil then
    TheWorld.net:ListenForEvent("warnquake", core.Wrap(function()
      core.Announce(S.quake_warning)
    end))
  end
end))
