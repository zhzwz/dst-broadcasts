--- 天气播报：跨天时按分片播报一句当前天气（仅 forest/cave；首日不播见 watch_cycles）

mod.Watch.Cycles(function()
  local message = mod.World.GetWeatherDescription()
  if message ~= "" then
    mod.Announce(message)
  end
end)
