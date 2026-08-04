--[[
  日历：跨天时播报绝对日、当前天气一词、季节进度与距下季天数。
]]

modimport("scripts/broadcasts/lib/current_weather.lua")

local S = BROADCASTS_STRINGS
local ClassifyWeather = BROADCASTS_CURRENT_WEATHER.Classify

local NEXT_SEASON = {
  autumn = "winter",
  winter = "spring",
  spring = "summer",
  summer = "autumn",
}

local function AsInt(value, fallback)
  if type(value) ~= "number" or value ~= value or value == math.huge or value == -math.huge then
    return fallback
  end
  return math.floor(value + 0.5)
end

local function IsMoonstormActive()
  local net = TheWorld.net
  local moonstorms = net ~= nil and net.components.moonstorms or nil
  if moonstorms == nil or moonstorms.GetMoonstormNodes == nil then
    return false
  end
  local nodes = moonstorms:GetMoonstormNodes()
  return type(nodes) == "table" and next(nodes) ~= nil
end

local function WeatherLabel()
  local state = TheWorld.state
  local sandstorms = TheWorld.components.sandstorms
  local tuning = TUNING or {}
  local key = ClassifyWeather({
    precipitation = state.precipitation,
    precipitationrate = state.precipitationrate,
    sandstorm_active = sandstorms ~= nil and sandstorms:IsSandstormActive() or false,
    moonstorm_active = IsMoonstormActive(),
    heavy_rain_rate = tuning.FROG_RAIN_PRECIPITATION,
  })
  local labels = S.calendar_weather
  if type(labels) ~= "table" then
    return ""
  end
  local label = labels[key]
  if type(label) ~= "string" or label == "" then
    label = labels.clear
  end
  return type(label) == "string" and label or ""
end

local function AnnounceCalendar()
  local state = TheWorld.state
  if state == nil then
    return
  end

  local season = state.season
  local season_name = S.seasons ~= nil and S.seasons[season] or nil
  local next_key = NEXT_SEASON[season]
  local next_name = next_key ~= nil and S.seasons ~= nil and S.seasons[next_key] or nil
  if season_name == nil or next_name == nil then
    return
  end

  local weather = WeatherLabel()
  if weather == "" then
    return
  end

  local day = AsInt(state.cycles, 0) + 1
  local day_in_season = AsInt(state.elapseddaysinseason, 0) + 1
  local remaining = AsInt(state.remainingdaysinseason, 0)

  if remaining <= 0 then
    local template = S.calendar_report_soon
    if type(template) ~= "string" or template == "" then
      return
    end
    mod.Announce(string.format(template, day, weather, season_name, day_in_season, next_name))
    return
  end

  local template = S.calendar_report
  if type(template) ~= "string" or template == "" then
    return
  end
  mod.Announce(string.format(template, day, weather, season_name, day_in_season, next_name, remaining))
end

AddSimPostInit(mod.Wrap("calendar_init", function()
  if not TheWorld.ismastersim then
    return
  end

  -- 读档时 cycles 会从默认 0 跳到存档天数；只在真正跨天（+1）时播报。
  local prev_cycles = TheWorld.state.cycles
  TheWorld:WatchWorldState("cycles", mod.Wrap("calendar_cycles", function(_, cycles)
    local previous = prev_cycles
    prev_cycles = cycles
    if type(cycles) ~= "number" or type(previous) ~= "number" then
      return
    end
    if cycles ~= previous + 1 or cycles <= 0 then
      return
    end
    TheWorld:DoTaskInTime(0, mod.Wrap("calendar_report", AnnounceCalendar))
  end))
end))
