--- 判断当前是否有月亮风暴
--- @return boolean
local function IsMoonstormActive()
  if TheWorld == nil or TheWorld.net == nil or TheWorld.net.components == nil then
    return false
  end
  local moonstorms = TheWorld.net.components.moonstorms
  if moonstorms == nil or type(moonstorms.GetMoonstormNodes) ~= "function" then
    return false
  end
  local nodes = mod.Call("mod.World.IsMoonstormActive", moonstorms.GetMoonstormNodes, moonstorms)
  return type(nodes) == "table" and next(nodes) ~= nil
end

--- 判断当前是否有沙尘暴
--- @return boolean
local function IsSandstormActive()
  if TheWorld == nil or TheWorld.components == nil then
    return false
  end
  local sandstorms = TheWorld.components.sandstorms
  if sandstorms == nil or type(sandstorms.IsSandstormActive) ~= "function" then
    return false
  end
  return mod.Call("mod.World.IsSandstormActive", sandstorms.IsSandstormActive, sandstorms) == true
end

local function GetPrecipitationRateKey(rate)
  if type(rate) == "number" then
    if rate <= 0.25 then
      return "light"
    elseif rate >= 0.75 then
      return "storm"
    elseif rate >= 0.5 then
      return "heavy"
    end
  end
  return "normal"
end

--- 获取天气编码列表
--- @return WeatherKey[]
local function GetWeatherKeys()
  --- @type WeatherKey[]
  local keys = {}
  --- @type World|nil
  local world = TheWorld
  local state = world ~= nil and world.state or nil
  if state ~= nil then
    local p = state.precipitation
    local r = state.precipitationrate
    if p == "acidrain" then
      table.insert(keys, "acidrain")
    elseif p == "lunarhail" then
      table.insert(keys, "lunarhail")
    elseif p == "snow" then
      table.insert(keys, "snow_" .. GetPrecipitationRateKey(r))
    elseif p == "rain" then
      table.insert(keys, "rain_" .. GetPrecipitationRateKey(r))
    else
      table.insert(keys, "sunny")
    end
  end

  if IsSandstormActive() then
    table.insert(keys, "sandstorm")
  end
  if IsMoonstormActive() then
    table.insert(keys, "moonstorm")
  end
  if #keys == 0 then
    table.insert(keys, "sunny")
  end
  return keys
end

--- @param keys WeatherKey[]|nil
--- @return string
local function FormatWeatherParts(keys)
  local labels = i18n.weather
  if type(labels) ~= "table" or type(keys) ~= "table" then
    return ""
  end

  local parts = {}
  for _, key in ipairs(keys) do
    local label = labels[key]
    if type(label) == "string" and label ~= "" then
      table.insert(parts, label)
    end
  end
  if #parts == 0 then
    return ""
  end

  local sep = labels.separator
  if type(sep) ~= "string" then
    sep = ", "
  end
  return table.concat(parts, sep)
end

--- @param is_cave boolean
--- @param keys WeatherKey[]|nil
--- @return string
local function FormatWeatherReport(is_cave, keys)
  local labels = i18n.weather
  if type(labels) ~= "table" then
    return ""
  end

  local parts = FormatWeatherParts(keys)
  if parts == "" then
    return ""
  end

  local template = is_cave and labels.report_cave or labels.report_forest
  if type(template) ~= "string" or template == "" then
    return ""
  end

  return string.format(template, parts)
end

--- 森林 + 洞穴两句拼成一条（缺一侧则只保留有的）
--- @param forest_keys WeatherKey[]|nil
--- @param cave_keys WeatherKey[]|nil
--- @return string
local function FormatMergedWeatherReport(forest_keys, cave_keys)
  local forest = FormatWeatherReport(false, forest_keys)
  local cave = FormatWeatherReport(true, cave_keys)
  if forest == "" then
    return cave
  end
  if cave == "" then
    return forest
  end
  return forest .. cave
end

mod.World.IsMoonstormActive = IsMoonstormActive
mod.World.IsSandstormActive = IsSandstormActive
mod.World.GetWeatherKeys = GetWeatherKeys
mod.World.FormatMergedWeatherReport = FormatMergedWeatherReport

--- 月雹
--- 在森林世界，当裂隙（月亮）存在时，每隔 10 天将会降下一场月雹，每次持续 90 秒。
--- 月雹发生时，如果当前正在发生降水，将会打断正在发生的降水。
--- 月雹期间，水分值持续消耗，因此在月雹结束时不会恢复之前的降水。
