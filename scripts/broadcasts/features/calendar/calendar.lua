--[[
  日历：跨天时播报绝对日、季节进度与距下季天数。
]]

local S = i18n

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

  local day = AsInt(state.cycles, 0) + 1
  local day_in_season = AsInt(state.elapseddaysinseason, 0) + 1
  local remaining = AsInt(state.remainingdaysinseason, 0)

  if remaining <= 0 then
    local template = S.calendar_report_soon
    if type(template) ~= "string" or template == "" then
      return
    end
    mod.Announce(string.format(template, day, season_name, day_in_season, next_name))
    return
  end

  local template = S.calendar_report
  if type(template) ~= "string" or template == "" then
    return
  end
  mod.Announce(string.format(template, day, season_name, day_in_season, next_name, remaining))
end

mod.Watch.Cycles(AnnounceCalendar)
