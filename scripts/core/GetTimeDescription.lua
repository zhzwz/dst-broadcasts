local function GetTimeDescription(seconds)
  if type(seconds) ~= "number" or seconds ~= seconds or seconds <= 0 then
    seconds = 0
  else
    seconds = math.floor(seconds)
  end

  local t = i18n.time
  local h = math.floor(seconds / 3600)
  local m = math.floor((seconds % 3600) / 60)
  local s = seconds % 60

  local parts = {}
  if h > 0 then
    table.insert(parts, string.format(t.hours, h))
  end
  if m > 0 then
    table.insert(parts, string.format(t.minutes, m))
  end
  if s > 0 or #parts == 0 then
    table.insert(parts, string.format(t.seconds, s))
  end
  return table.concat(parts, t.sep)
end

core.GetTimeDescription = GetTimeDescription
