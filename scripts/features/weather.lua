--- 天气公告：降水类型 / 雨雪档位变化时公告（仅主机）。
--- 不含沙尘暴、月亮风暴、酸雨（酸雨见 cave.lua）；读档首帧不公告；同帧多事件合并为一句。

local labels = i18n.weather

local TEXT_FOREST_WORLD = STRINGS.UI.SERVERCREATIONSCREEN.FORESTWORLD
local TEXT_CAVE_WORLD = STRINGS.UI.SERVERCREATIONSCREEN.CAVEWORLD
local TEXT_LUNARHAIL = STRINGS.UI.CUSTOMIZATIONSCREEN.LUNARHAIL_FREQUENCY

local ready = false
local precipitation = "none"
local rate = 0
local signature_previous = nil
local announce_scheduled = false

--- 雨雪强度档位：light / normal / heavy / storm。
local function GetPrecipitationRateKey(value)
  if type(value) == "number" then
    if value <= 0.25 then
      return "light"
    elseif value >= 0.75 then
      return "storm"
    elseif value >= 0.5 then
      return "heavy"
    end
  end
  return "normal"
end

--- @return string
local function GetPrecipitationKey()
  if precipitation == "acidrain" then
    return "acidrain"
  elseif precipitation == "lunarhail" then
    return "lunarhail"
  elseif precipitation == "snow" then
    return "snow_" .. GetPrecipitationRateKey(rate)
  elseif precipitation == "rain" then
    return "rain_" .. GetPrecipitationRateKey(rate)
  end
  return "sunny"
end

--- @param key string
--- @return string|nil
local function GetPrecipitationLabel(key)
  if key == "lunarhail" then
    return TEXT_LUNARHAIL or labels.lunarhail
  end
  local label = labels[key]
  if type(label) == "string" and label ~= "" then
    return label
  end
  return nil
end

local function AnnounceWeather()
  if not ready then
    return
  end
  local signature = GetPrecipitationKey()
  if signature == signature_previous then
    return
  end
  signature_previous = signature
  --- 酸雨不公告（洞穴由 cave 功能单独公告）
  if signature == "acidrain" then
    return
  end

  local precip_label = GetPrecipitationLabel(signature)
  if precip_label == nil then
    return
  end

  local world_name
  if core.World.IsCave() then
    world_name = TEXT_CAVE_WORLD
  elseif core.World.IsForest() then
    world_name = TEXT_FOREST_WORLD
  else
    return
  end
  local template = labels.report
  if type(world_name) ~= "string" or world_name == "" then
    return
  end
  if type(template) ~= "string" or template == "" then
    return
  end

  core.Announce(string.format(template, world_name, precip_label))
end

local function ScheduleAnnounce()
  if announce_scheduled or TheWorld == nil then
    return
  end
  announce_scheduled = true
  TheWorld:DoTaskInTime(0, core.Wrap(function()
    announce_scheduled = false
    AnnounceWeather()
  end))
end

core.World.ListenPrecipitation("server", function(value)
  precipitation = value or "none"
  ScheduleAnnounce()
end)

core.World.ListenPrecipitationRate("server", function(value)
  rate = type(value) == "number" and value or 0
  --- 仅雨/雪的档位变化会影响文案
  if precipitation == "rain" or precipitation == "snow" then
    ScheduleAnnounce()
  end
end)

AddSimPostInit(core.Wrap(function()
  if not core.World.IsServerSide() then
    return
  end
  --- 读档首帧只对齐快照，不公告（避免空服白公告）
  TheWorld:DoTaskInTime(0, core.Wrap(function()
    local state = TheWorld.state
    if state ~= nil then
      precipitation = state.precipitation or "none"
      rate = type(state.precipitationrate) == "number" and state.precipitationrate or 0
    end
    signature_previous = GetPrecipitationKey()
    ready = true
  end))
end))

--- 月雹
--- 在森林世界，当裂隙（月亮）存在时，每隔 10 天将会降下一场月雹，每次持续 90 秒。
--- 月雹发生时，如果当前正在发生降水，将会打断正在发生的降水。
--- 月雹期间，水分值持续消耗，因此在月雹结束时不会恢复之前的降水。
