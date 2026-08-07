--- 监听天气相关变化（仅主机）。
--- 按间隔轮询快照（降水 / 沙尘 / 月风暴）；读档首帧不回调。
--- 去重只比较 keys（含雨量档位 light/normal/heavy/storm）：同档内 precipitationrate
--- 微变不回调；event 仍带原始 precipitation / precipitationrate，但仅在 keys 变化时更新。
--- @alias ListenWeatherEvent { keys: string[], precipitation: string|nil, precipitationrate: number|nil }

local INTERVAL_SECONDS = 5

local listeners = {}
local scheduled = false
local ready = false
local last_signature = nil

local function IsMoonstormActive()
  if TheWorld == nil or TheWorld.net == nil or TheWorld.net.components == nil then
    return false
  end
  local moonstorms = TheWorld.net.components.moonstorms
  if moonstorms == nil or type(moonstorms.GetMoonstormNodes) ~= "function" then
    return false
  end
  local nodes = core.Call(moonstorms.GetMoonstormNodes, moonstorms)
  return type(nodes) == "table" and next(nodes) ~= nil
end

local function IsSandstormActive()
  if TheWorld == nil or TheWorld.components == nil then
    return false
  end
  local sandstorms = TheWorld.components.sandstorms
  if sandstorms == nil or type(sandstorms.IsSandstormActive) ~= "function" then
    return false
  end
  return core.Call(sandstorms.IsSandstormActive, sandstorms) == true
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

--- @return string[], string|nil, number|nil
local function BuildWeatherSnapshot()
  --- @type string[]
  local keys = {}
  local precipitation = nil
  local precipitationrate = nil
  local state = TheWorld ~= nil and TheWorld.state or nil
  if state ~= nil then
    precipitation = state.precipitation
    precipitationrate = state.precipitationrate
    if precipitation == "acidrain" then
      table.insert(keys, "acidrain")
    elseif precipitation == "lunarhail" then
      table.insert(keys, "lunarhail")
    elseif precipitation == "snow" then
      table.insert(keys, "snow_" .. GetPrecipitationRateKey(precipitationrate))
    elseif precipitation == "rain" then
      table.insert(keys, "rain_" .. GetPrecipitationRateKey(precipitationrate))
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
  return keys, precipitation, precipitationrate
end

--- 签名只拼 keys，故意忽略原始 precipitationrate（同档微变不通知）。
local function KeysSignature(keys)
  return table.concat(keys, "\0")
end

local function NotifyListeners()
  if not ready or #listeners == 0 then
    return
  end
  local keys, precipitation, precipitationrate = BuildWeatherSnapshot()
  local signature = KeysSignature(keys)
  if signature == last_signature then
    return
  end
  last_signature = signature
  local event = {
    keys = keys,
    precipitation = precipitation,
    precipitationrate = precipitationrate,
  }
  for i = 1, #listeners do
    core.Call(listeners[i], event)
  end
end

local function StartPolling()
  if not core.IsServer() or TheWorld == nil then
    return
  end
  local keys0 = BuildWeatherSnapshot()
  last_signature = KeysSignature(keys0)
  core.SetInterval(TheWorld, NotifyListeners, INTERVAL_SECONDS)
  --- 首帧后再接受变化，避免读档瞬间误播
  core.SetTimeout(TheWorld, function()
    local keys = BuildWeatherSnapshot()
    last_signature = KeysSignature(keys)
    ready = true
  end, 0)
end

local function EnsureScheduled()
  if scheduled then
    return
  end
  scheduled = true
  --- Sim 已就绪则立刻开轮询；否则等 SimPostInit（过晚注册时 AddSimPostInit 不会再跑）
  if TheWorld ~= nil then
    StartPolling()
  else
    AddSimPostInit(core.Wrap(StartPolling))
  end
end

--- @param fn fun(event: ListenWeatherEvent)
core.ListenWeather = function(fn)
  if type(fn) ~= "function" then
    return
  end
  table.insert(listeners, fn)
  EnsureScheduled()
end
