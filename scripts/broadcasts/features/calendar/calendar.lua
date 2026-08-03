--[[
  日历：跨天时播报绝对日、季节进度与距下季天数。
]]

local S = BROADCASTS_STRINGS
local C = BROADCASTS_CONSTANTS
local Safe = BROADCASTS_SAFE

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
  local next_key = C.NEXT_SEASON[season]
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
    Safe.Announce(string.format(template, day, season_name, day_in_season, next_name))
    return
  end

  local template = S.calendar_report
  if type(template) ~= "string" or template == "" then
    return
  end
  Safe.Announce(string.format(template, day, season_name, day_in_season, next_name, remaining))
end

AddSimPostInit(Safe.Wrap("calendar_init", function()
  if not TheWorld.ismastersim then
    return
  end

  -- 读档时 cycles 会从默认 0 跳到存档天数；只在真正跨天（+1）时播报。
  local prev_cycles = TheWorld.state.cycles
  TheWorld:WatchWorldState("cycles", Safe.Wrap("calendar_cycles", function(_, cycles)
    local previous = prev_cycles
    prev_cycles = cycles
    if type(cycles) ~= "number" or type(previous) ~= "number" then
      return
    end
    if cycles ~= previous + 1 or cycles <= 0 then
      return
    end
    TheWorld:DoTaskInTime(0, Safe.Wrap("calendar_report", AnnounceCalendar))
  end))
end))
