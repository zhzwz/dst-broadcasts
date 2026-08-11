--- 青蛙雨：第一只雨蛙落地时开场公告；结束时分别统计青蛙 / 明眼青蛙。
--- 仅地表主机；洞穴跳过。
--- 开始看 StartTracking 首次计入 frog / lunarfrog（非天气条件）；结束看原版产蛙条件不再满足。
--- 读档：POPULATING / 首帧前只打标不计增；DoTaskInTime(0) 后再响应计增与结算。

local s = i18n.separator
local e = i18n.exclamation
local t = i18n.times

--- 已处理过的雨蛙（弱键，实体回收后自动掉；不往实体上写字段）
local counted_frogs = setmetatable({}, { __mode = "k" })

--- 读档/首帧完成前不计增，避免 OnLoad 重入 StartTracking 叠在存档计数上。
local ready = false

--- 按 prefab 读取青蛙雨计数；无效则为 0。
--- @param prefab string
--- @return number
local function GetCount(prefab)
  local counts = GetWorldStateComponent():Get(STATE_WORLD_FROGRAIN_COUNT)
  if type(counts) ~= "table" then return 0 end
  local value = counts[prefab]
  if type(value) ~= "number" or value ~= value then return 0 end
  return value
end

--- 按 prefab 写入青蛙雨计数。
--- @param prefab string
--- @param value number
local function SetCount(prefab, value)
  local state = GetWorldStateComponent()
  local counts = state:Get(STATE_WORLD_FROGRAIN_COUNT)
  if type(counts) ~= "table" then
    counts = {}
    state:Set(STATE_WORLD_FROGRAIN_COUNT, counts)
  end
  counts[prefab] = value
end

--- 当前是否仍满足原版产蛙条件（对齐 frograin.ToggleUpdate）。
--- @return boolean
local function IsSpawning()
  local state = TheWorld.state
  if state == nil then return false end
  if not state.isspring or not state.israining then return false end
  local rate = state.precipitationrate
  local ceil = state.moistureceil
  --- 非数字 / NaN 视为未产蛙，避免比较异常打断结算
  if type(rate) ~= "number" or rate ~= rate then return false end
  if type(ceil) ~= "number" or ceil ~= ceil then return false end
  return rate > TUNING.FROG_RAIN_PRECIPITATION and ceil > TUNING.FROG_RAIN_MOISTURE
end

--- 开始
local function Start()
  local state = GetWorldStateComponent()
  if state:Get(STATE_WORLD_FROGRAIN_STARTED, false) then return end
  state:Set(STATE_WORLD_FROGRAIN_STARTED, true)
  DST_SERVER_SEND(TEXT_FROGRAIN .. s .. i18n.started .. e)
end

--- 结束（未 ready 或仍在产蛙时直接返回）
local function End()
  if not ready or IsSpawning() then return end
  local state = GetWorldStateComponent()
  if not state:Get(STATE_WORLD_FROGRAIN_STARTED, false) then return end
  local frog_count = GetCount(PREFAB_FROG)
  local lunar_frog_count = GetCount(PREFAB_LUNAR_FROG)

  state:Set(STATE_WORLD_FROGRAIN_STARTED, nil)
  state:Set(STATE_WORLD_FROGRAIN_COUNT, nil)
  counted_frogs = setmetatable({}, { __mode = "k" })

  if frog_count > 0 or lunar_frog_count > 0 then
    DST_SERVER_SEND(TEXT_FROGRAIN .. s .. i18n.ended .. e)
  end

  if frog_count > 0 then
    local name = core.GetPrefabDisplayName(PREFAB_FROG)
    DST_SERVER_SEND(name .. s .. t .. s .. frog_count)
  end

  if lunar_frog_count > 0 then
    local name = core.GetPrefabDisplayName(PREFAB_LUNAR_FROG)
    DST_SERVER_SEND(name .. s .. t .. s .. lunar_frog_count)
  end
end

--- 官方只在森林 master_postinit 中挂载 frograin，客户端或洞穴不会执行。
AddComponentPostInit("frograin", function(self)
  DST_HOOK(self, "StartTracking", function(component, target)
    if target == nil or counted_frogs[target] then return end
    local prefab = target.prefab
    if prefab ~= PREFAB_FROG and prefab ~= PREFAB_LUNAR_FROG then return end
    --- 先记入去重表；读档阶段只信任存档计数，不计增 / 不公告「开始」
    counted_frogs[target] = true
    if POPULATING or not ready then return end
    Start()
    SetCount(prefab, GetCount(prefab) + 1)
  end)
end)

AddSimPostInit(core.Wrap(function()
  if not core.World.IsServerSide() or not core.World.IsForest() then return end
  --- 产蛙条件变化时尝试结算结束
  local TryEnd = core.Wrap(End)
  TheWorld:WatchWorldState("isspring", TryEnd)
  TheWorld:WatchWorldState("israining", TryEnd)
  TheWorld:WatchWorldState("precipitationrate", TryEnd)
  TheWorld:WatchWorldState("moistureceil", TryEnd)

  --- 读档还原世界状态时可能同步触发 WatchWorldState / StartTracking；首帧后再接受变化与计增。
  --- ready 打开后补跑一次结束检查，避免门闩窗口内错过结算导致场次粘连。
  TheWorld:DoTaskInTime(0, core.Wrap(function()
    ready = true
    TryEnd()
  end))

  if not IsSpawning() then return end
  if GetCount(PREFAB_FROG) + GetCount(PREFAB_LUNAR_FROG) <= 0 then return end
  --- 读档时雨仍在下且已有计数，默认允许公告。
  Start()
  --- 已存在的青蛙记入去重表，避免 StartTracking 重复计数。
  for frog in pairs(TheWorld.components.frograin._frogs) do
    if frog ~= nil then counted_frogs[frog] = true end
  end
end))
