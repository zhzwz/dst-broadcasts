--- 青蛙雨：第一只雨蛙落地时开场播报；结束时分别统计青蛙 / 明眼青蛙。
--- 仅地表主机；洞穴跳过。
--- 开始看 StartTracking 首次计入 frog / lunarfrog（非天气条件）；结束看原版产蛙条件不再满足。
--- 读档：POPULATING / 首帧前只打标不计增；SetTimeout(0) 后再响应计增与结算。

local S = i18n

--- 持久化状态键（勿改名，避免存档计数丢失）
local ACTIVE_KEY = "frog_rain_active"
local COUNT_KEY = "frog_rain_count"
local LUNAR_COUNT_KEY = "frog_rain_lunar_count"

local FROG_PREFAB = "frog"
local LUNAR_FROG_PREFAB = "lunarfrog"

--- 实体去重标记（内存，不入档）
local COUNTED_FLAG = "_dst_broadcasts_frog_counted"

--- 读档/首帧完成前不计增，避免 OnLoad 重入 StartTracking 叠在存档计数上。
local ready = false

local function GetState(world)
  return world.components.state_3774915634
end

--- 与原版 frograin.ToggleUpdate 的开启条件一致（仅用于判断何时结算场次）。
--- 字段缺失或非数字时视为未在产蛙，避免比较抛错导致结束结算被吞。
local function IsFrogRainSpawning(world)
  local state = world.state
  if state == nil or not state.isspring or not state.israining then
    return false
  end
  local rate = state.precipitationrate
  local ceil = state.moistureceil
  if type(rate) ~= "number" or rate ~= rate or type(ceil) ~= "number" or ceil ~= ceil then
    return false
  end
  return rate > TUNING.FROG_RAIN_PRECIPITATION and ceil > TUNING.FROG_RAIN_MOISTURE
end

local function ClearFrogRainState(world)
  local state = GetState(world)
  if state == nil then
    return
  end
  state:Set(ACTIVE_KEY, nil)
  state:Set(COUNT_KEY, nil)
  state:Set(LUNAR_COUNT_KEY, nil)
end

local function SessionCounts(state)
  local frogs = state:Get(COUNT_KEY, 0) or 0
  local lunar = state:Get(LUNAR_COUNT_KEY, 0) or 0
  return frogs, lunar
end

local function AnnounceStarted()
  local template = core.RandomPick(S.frog_rain_started)
  if template == nil then
    return
  end
  core.Announce(template)
end

local function AnnounceEnded(frogs, lunar)
  if lunar > 0 then
    local template = core.RandomPick(S.frog_rain_ended_lunar)
    if template ~= nil then
      core.Announce(string.format(template, frogs, lunar))
      return
    end
  end
  local template = core.RandomPick(S.frog_rain_ended)
  if template == nil then
    return
  end
  core.Announce(string.format(template, frogs))
end

--- 读档后已在场的雨蛙打上去重标记，避免 StartTracking 重入导致重复计数。
local function MarkExistingTracked(world)
  local frograin = world.components.frograin
  if frograin == nil or type(frograin._frogs) ~= "table" then
    return
  end
  for frog in pairs(frograin._frogs) do
    if frog ~= nil then
      frog[COUNTED_FLAG] = true
    end
  end
end

--- 开启场次；已在进行中则跳过。announce=false 用于读档对齐。
local function EnsureSession(world, announce)
  local state = GetState(world)
  if state == nil or state:Get(ACTIVE_KEY, false) then
    return
  end
  state:Set(ACTIVE_KEY, true)
  if announce then
    AnnounceStarted()
  end
end

local function CountFrog(world, target)
  if target == nil or not target:IsValid() or target[COUNTED_FLAG] then
    return
  end

  local prefab = target.prefab
  if prefab ~= FROG_PREFAB and prefab ~= LUNAR_FROG_PREFAB then
    return
  end

  --- 先打标；读档阶段只信任存档计数，不 Increment / 不播「开始」
  target[COUNTED_FLAG] = true
  if POPULATING or not ready then
    return
  end

  EnsureSession(world, true)

  local state = GetState(world)
  if state == nil then
    return
  end

  if prefab == LUNAR_FROG_PREFAB then
    state:Increment(LUNAR_COUNT_KEY)
  else
    state:Increment(COUNT_KEY)
  end
end

local function FinishFrogRain(world)
  local state = GetState(world)
  if state == nil or not state:Get(ACTIVE_KEY, false) then
    return
  end

  local frogs, lunar = SessionCounts(state)
  ClearFrogRainState(world)

  if frogs + lunar > 0 then
    AnnounceEnded(frogs, lunar)
  end
end

AddComponentPostInit("frograin", function(self)
  local old_start_tracking = self.StartTracking
  self.StartTracking = function(component, target)
    old_start_tracking(component, target)
    core.Call(CountFrog, component.inst, target)
  end
end)

AddSimPostInit(core.Wrap(function()
  if not core.IsServer() or core.IsCaveWorld() then
    return
  end

  local on_condition = core.Wrap(function()
    if ready and not IsFrogRainSpawning(TheWorld) then
      FinishFrogRain(TheWorld)
    end
  end)

  TheWorld:WatchWorldState("isspring", on_condition)
  TheWorld:WatchWorldState("israining", on_condition)
  TheWorld:WatchWorldState("precipitationrate", on_condition)
  TheWorld:WatchWorldState("moistureceil", on_condition)

  --- 读档还原世界状态时可能同步触发 WatchWorldState / StartTracking；首帧后再接受变化与计增。
  --- ready 打开后补跑一次结束检查，避免门闩窗口内错过结算导致场次粘连。
  core.SetTimeout(TheWorld, function()
    ready = true
    on_condition()
  end, 0)

  local state = GetState(TheWorld)
  local frogs, lunar = 0, 0
  if state ~= nil then
    frogs, lunar = SessionCounts(state)
  end

  if IsFrogRainSpawning(TheWorld) and frogs + lunar > 0 then
    --- 读档时雨仍在下且已有计数：静默恢复场次，避免重播「开始」与重复计数
    EnsureSession(TheWorld, false)
    MarkExistingTracked(TheWorld)
  else
    --- 雨已停或无有效计数：丢弃未结算，避免读档瞬间误播
    ClearFrogRainState(TheWorld)
  end
end))
