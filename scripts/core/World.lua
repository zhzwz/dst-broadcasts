--- @alias WorldSide "server" | "client" | "both"

local function IsClientSide()
  return TheWorld ~= nil and TheWorld.ismastersim == false
end

local function IsServerSide()
  return TheWorld ~= nil and TheWorld.ismastersim == true
end

--- @param side WorldSide
local function IsCorrectSide(side)
  return side == "both"
      or (side == "server" and IsServerSide())
      or (side == "client" and IsClientSide())
end

local function IsForest()
  return core.HasTag(TheWorld, "forest")
end

local function IsCave()
  return core.HasTag(TheWorld, "cave")
end

--- 当前是否有月亮风暴。
local function IsMoonstormActive()
  if TheWorld == nil then return false end
  if TheWorld.net == nil then return false end
  if TheWorld.net.components == nil then return false end
  local moonstorms = TheWorld.net.components.moonstorms
  if moonstorms == nil then return false end
  if type(moonstorms.GetMoonstormNodes) ~= "function" then return false end
  return next(moonstorms:GetMoonstormNodes()) ~= nil
end

--- 当前是否有沙尘暴。
local function IsSandstormActive()
  if TheWorld == nil then return false end
  if TheWorld.components == nil then return false end
  local sandstorms = TheWorld.components.sandstorms
  if sandstorms == nil then return false end
  if type(sandstorms.IsSandstormActive) ~= "function" then return false end
  return sandstorms:IsSandstormActive() == true
end

--- 监听昼夜循环轮数变化。
--- @param side WorldSide
--- @param callback fun(cycles: number)
local function ListenCycles(side, callback)
  AddSimPostInit(core.Wrap(function()
    if not IsCorrectSide(side) then return end
    --- 会话开始时记下的已是当前 cycles（读档/回档为重建世界）；cycles 从 0 起
    local cycles_prev = core.Number(TheWorld.state.cycles) or 0
    TheWorld:WatchWorldState("cycles", core.Wrap(function(_, cycles)
      local cycles_new = core.Number(cycles) or 0
      local prev = cycles_prev
      cycles_prev = cycles_new
      --- 本局内非连续跳变不触发
      if prev + 1 ~= cycles_new then return end
      --- 延后到本帧末，避免与同期 WatchWorldState 打架
      TheWorld:DoTaskInTime(0, core.Wrap(function()
        callback(cycles_new)
      end))
    end))
  end))
end

local NEXT_PHASE = { day = "dusk", dusk = "night", night = "day" }

--- 监听昼夜相位变化。
--- @param side WorldSide
--- @param callback fun(phase: string)
local function ListenPhase(side, callback)
  AddSimPostInit(core.Wrap(function()
    if not IsCorrectSide(side) then return end
    --- 森林看 phase，洞穴看 cavephase
    local key = IsCave() and "cavephase" or "phase"
    --- 会话开始时记下的已是当前相位（读档/回档为重建世界）
    local phase_prev = TheWorld.state ~= nil and TheWorld.state[key] or nil
    TheWorld:WatchWorldState(key, core.Wrap(function(_, phase)
      local prev = phase_prev
      phase_prev = phase
      --- 仅 prev → 下一相位时回调
      if prev == nil or NEXT_PHASE[prev] ~= phase then return end
      --- 延后到本帧末，避免与同期 WatchWorldState 打架
      TheWorld:DoTaskInTime(0, core.Wrap(function() callback(phase) end))
    end))
  end))
end

--- 监听降水类型变化。
--- @param side WorldSide
--- @param callback fun(precipitation: PrecipitationType)
local function ListenPrecipitation(side, callback)
  AddSimPostInit(core.Wrap(function()
    if not IsCorrectSide(side) then return end
    --- 初值固定 "none"：读档/进服时若已是其它降水，相对初值会回调一次（预期）
    local precipitation_previous = "none"
    TheWorld:WatchWorldState("precipitation", core.Wrap(function(_, precipitation)
      if precipitation_previous ~= precipitation then
        TheWorld:DoTaskInTime(0, core.Wrap(function() callback(precipitation) end))
      end
      precipitation_previous = precipitation
    end))
    TheWorld:DoTaskInTime(0, core.Wrap(function()
      local precipitation = TheWorld.state.precipitation
      if (precipitation_previous ~= precipitation) then
        callback(precipitation)
        precipitation_previous = precipitation
      end
    end))
  end))
end

--- 监听降水强度数值变化（跨 0.1 台阶才回调）。
--- @param side WorldSide
--- @param callback fun(rate: number)
local function ListenPrecipitationRate(side, callback)
  AddSimPostInit(core.Wrap(function()
    if not IsCorrectSide(side) then return end
    --- 初值固定 0
    --- 游戏加载完成后，若已降雨，则短时间内很快触发，属于预期行为
    --- 游戏加载完成后，若无降雨，则短时间内不会触发，属于预期行为
    local rate_previous = 0
    TheWorld:WatchWorldState("precipitationrate", core.Wrap(function(_, rate)
      if math.floor(rate_previous * 10 + 1e-6) ~= math.floor(rate * 10 + 1e-6) then
        TheWorld:DoTaskInTime(0, core.Wrap(function() callback(rate) end))
      end
      rate_previous = rate
    end))
  end))
end

--- 监听沙尘暴。
--- @param side WorldSide
--- @param callback fun(active: boolean)
local function ListenSandstorm(side, callback)
  AddSimPostInit(core.Wrap(function()
    if not IsCorrectSide(side) then return end
    --- @param data MsStormChangedData|nil
    TheWorld:ListenForEvent("ms_stormchanged", core.Wrap(function(_, data)
      if data == nil or data.stormtype ~= STORM_TYPES.SANDSTORM then return end
      callback(data.setting == true)
    end))
  end))
end

--- 监听月亮风暴，月亮风暴移动也触发回调。
--- @param side WorldSide
--- @param callback fun(active: boolean)
local function ListenMoonstorm(side, callback)
  AddSimPostInit(core.Wrap(function()
    if not IsCorrectSide(side) then return end
    --- @param data MsStormChangedData|nil
    TheWorld:ListenForEvent("ms_stormchanged", core.Wrap(function(_, data)
      if data == nil or data.stormtype ~= STORM_TYPES.MOONSTORM then return end
      callback(data.setting == true)
    end))
  end))
end

core.World.IsClientSide = IsClientSide
core.World.IsServerSide = IsServerSide
core.World.IsCorrectSide = IsCorrectSide
core.World.IsForest = IsForest
core.World.IsCave = IsCave
core.World.IsMoonstormActive = IsMoonstormActive
core.World.IsSandstormActive = IsSandstormActive
core.World.ListenCycles = ListenCycles
core.World.ListenPhase = ListenPhase
core.World.ListenPrecipitation = ListenPrecipitation
core.World.ListenPrecipitationRate = ListenPrecipitationRate
core.World.ListenSandstorm = ListenSandstorm
core.World.ListenMoonstorm = ListenMoonstorm
