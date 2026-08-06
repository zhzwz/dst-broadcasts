--- 天气播报：跨天合并森林 / 洞穴为一句（首日不播见 watch_cycles）
--- 洞穴把 keys 发给 Master；森林等一会后本分片 Announce（全服可见）。
--- 永久开启，不提供配置项（与日历开关无关；关闭日历不影响天气）。

local WAIT = 1.5

--- 洞穴上报缓存（按 cycles 对齐）
local cave_cycles, cave_keys = nil, nil

local function decode_keys(encoded)
  --- @type WeatherKey[]
  local keys = {}
  if type(encoded) == "string" and encoded ~= "" then
    for part in string.gmatch(encoded, "[^,]+") do
      table.insert(keys, part)
    end
  end
  return keys
end

mod.Watch.Cycles(function(cycles)
  local keys = mod.World.GetWeatherKeys()

  if mod.World.IsCave() then
    if not mod.Shard.SendToMain("WeatherCaveKeys", { cycles = cycles, keys = keys }) then
      mod.Announce(mod.World.FormatMergedWeatherReport(nil, keys))
    end
    return
  end

  if not mod.World.IsForest() then
    return
  end

  if not mod.Shard.HasRemote() then
    mod.Announce(mod.World.FormatMergedWeatherReport(keys, nil))
    return
  end

  TheWorld:DoTaskInTime(WAIT, mod.Wrap("weather_merge", function()
    local remote = (cave_cycles == cycles) and cave_keys or nil
    if cave_cycles == cycles then
      cave_cycles, cave_keys = nil, nil
    end
    mod.Announce(mod.World.FormatMergedWeatherReport(keys, remote))
  end))
end)

mod.Shard.On("WeatherCaveKeys", function(from_shard, fields)
  if not mod.World.IsForest() then
    return
  end
  local cycles = tonumber(fields.cycles)
  if type(cycles) ~= "number" then
    return
  end
  cave_cycles, cave_keys = cycles, decode_keys(fields.keys)
end)
