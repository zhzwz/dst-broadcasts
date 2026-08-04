--[[
  当前天气一词分类（无 DST 硬依赖）。
  返回 calendar_weather 键；调用方再映射到文案。
]]

local DEFAULT_HEAVY_RATE = 0.55

local function AsNumber(value, fallback)
  if type(value) ~= "number" or value ~= value or value == math.huge or value == -math.huge then
    return fallback
  end
  return value
end

--- input:
---   precipitation, precipitationrate
---   sandstorm_active, moonstorm_active
---   heavy_rain_rate（可选；默认对齐 TUNING.FROG_RAIN_PRECIPITATION）
local function Classify(input)
  if type(input) ~= "table" then
    return "clear"
  end

  -- precipitation：none / rain / snow / acidrain / lunarhail
  local p = input.precipitation
  local rate = AsNumber(input.precipitationrate, 0)
  local heavy = AsNumber(input.heavy_rain_rate, DEFAULT_HEAVY_RATE)

  if p == "acidrain" then
    return "acidrain"
  end
  if p == "lunarhail" then
    return "lunarhail"
  end
  if p == "snow" then
    return "snow"
  end
  if p == "rain" then
    if rate > heavy then
      return "heavy_rain"
    end
    return "rain"
  end

  if input.sandstorm_active then
    return "sandstorm"
  end
  if input.moonstorm_active then
    return "moonstorm"
  end
  return "clear"
end

BROADCASTS_CURRENT_WEATHER = {
  Classify = Classify,
}
