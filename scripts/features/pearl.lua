--- Pearl（寄居蟹隐士）好感与待办任务。
--- 触发：公频精确发送 pearl（洞穴可跨片查地表，不限频率）；好感提升自动公告（每个游戏日最多一次）。
--- 跨片查询由主分片直接 Announce，无 token / 超时收尾。

--- spell:ignore autum
--- 任务 id / 文案键，需与游戏 prefabs/hermitcrab.lua 中 TASKS 一致；key 对应 i18n.pearl_tasks。
local TASK_IDS = {
  { id = 1,  key = "FIX_HOUSE_1" },       --- 修房子（1 级）
  { id = 2,  key = "FIX_HOUSE_2" },       --- 修房子（2 级）
  { id = 3,  key = "FIX_HOUSE_3" },       --- 修房子（3 级）
  { id = 4,  key = "PLANT_FLOWERS" },     --- 种花
  { id = 5,  key = "REMOVE_JUNK" },       --- 清理海底垃圾
  { id = 6,  key = "PLANT_BERRIES" },     --- 整理浆果丛（施肥）
  { id = 7,  key = "FILL_MEATRACKS" },    --- 晾肉架挂满
  { id = 8,  key = "GIVE_HEAVY_FISH" },   --- 送 5 条重海鱼
  { id = 9,  key = "REMOVE_LUREPLANT" },  --- 清除食人花
  { id = 10, key = "GIVE_UMBRELLA" },     --- 下雨时送伞
  { id = 11, key = "GIVE_PUFFY_VEST" },   --- 下雪时送保温衣
  { id = 12, key = "GIVE_FLOWER_SALAD" }, --- 送花沙拉
  { id = 14, key = "GIVE_BIG_WINTER" },   --- 送冬季重鱼
  { id = 15, key = "GIVE_BIG_SUMMER" },   --- 送夏季重鱼
  { id = 16, key = "GIVE_BIG_SPRING" },   --- 送春季重鱼
  { id = 17, key = "GIVE_BIG_AUTUM" },    --- 送秋季重鱼（游戏拼写为 AUTUM）
  { id = 18, key = "MAKE_CHAIR" },        --- 做木椅并让她坐下
}

local S = i18n

local RPC_REQUEST = "PearlStatusRequest"
--- 按字节计；中文待办较长时需留余量
local STATUS_MESSAGE_MAX_LEN = 2048
--- 公频触发词（与 UpperString 比较）
local CHAT_TRIGGER = "PEARL"

local FRIEND_ANNOUNCE_CYCLE_KEY = "pearl_friend_announce_cycle"
local last_friend_announce_cycle = nil

local function FindPearl()
  local mbm = TheWorld ~= nil and TheWorld.components ~= nil and TheWorld.components.messagebottlemanager or nil
  if mbm ~= nil then
    if mbm.GetHermitCrab ~= nil then
      local pearl = mbm:GetHermitCrab()
      if pearl ~= nil then
        return pearl
      end
    elseif mbm.hermitcrab ~= nil and mbm.hermitcrab:IsValid() then
      return mbm.hermitcrab
    end
    --- 管理器未挂上实例时回退扫描，避免误报未找到
  end

  --- Pearl 只在主分片（地表）；非主分片不要扫 Ents
  local self_id = core.GetSelfShardId()
  if self_id == nil then
    return nil
  end
  if not core.IsMainShardId(self_id) then
    return nil
  end

  for _, ent in pairs(Ents) do
    if ent ~= nil
        and ent.prefab == "hermitcrab"
        and ent:IsValid()
        and ent.components ~= nil
        and ent.components.friendlevels ~= nil
    then
      return ent
    end
  end
  return nil
end

local function CollectPendingTasks(friendlevels)
  local tasks = friendlevels.friendlytasks
  if type(tasks) ~= "table" then
    return {}
  end

  local names = S.pearl_tasks
  local pending = {}
  for _, entry in ipairs(TASK_IDS) do
    local task = tasks[entry.id]
    if task ~= nil and not task.complete then
      local label = names ~= nil and names[entry.key] or entry.key
      table.insert(pending, label)
    end
  end
  return pending
end

--- 仅当本分片存在 Pearl 时返回文案；否则返回 nil
local function TryBuildLocalStatusMessage()
  local pearl = FindPearl()
  if pearl == nil then
    return nil
  end

  local friendlevels = pearl.components ~= nil and pearl.components.friendlevels or nil
  if friendlevels == nil then
    return nil
  end

  local level = friendlevels:GetLevel() or 0
  local max_level = friendlevels:GetMaxLevel() or 0
  local message = string.format(S.pearl_status, S.pearl_name, level, max_level)
  local pending = CollectPendingTasks(friendlevels)
  if #pending > 0 then
    message = message .. string.format(S.pearl_tasks_pending, table.concat(pending, S.symbol.enumeration))
  else
    message = message .. S.pearl_tasks_done
  end
  return message
end

--- 结构校验：允许跨分片语言配置不一致（含 x/y 好感格式即可）
local function IsValidStatusMessage(message)
  if type(message) ~= "string" or message == "" or #message > STATUS_MESSAGE_MAX_LEN then
    return false
  end
  if string.find(message, "[\r\n%z]", 1) ~= nil then
    return false
  end
  if string.find(message, "%d+/%d+") == nil then
    return false
  end
  return true
end

local function HasRemotePearlShard()
  --- Pearl 在地表；通常为 master。本分片已是主分片时不必再问其它分片。
  local self_id = core.GetSelfShardId()
  if self_id ~= nil and core.IsMainShardId(self_id) then
    return false
  end
  local main_id = core.GetMainShardId()
  if main_id ~= nil and type(Shard_IsWorldAvailable) == "function" then
    return Shard_IsWorldAvailable(main_id)
  end
  return core.HasRemoteShard()
end

--- TheNet:Announce 全服可见，任一主控分片公告一次即可
local function BroadcastStatus(message)
  if not IsValidStatusMessage(message) then
    return false
  end
  core.Announce(message)
  return true
end

--- 洞穴：向主分片要状态；文案由 Master 直接 Announce（不回传、无 token）
local function RequestRemoteStatus()
  local main_id = core.GetMainShardId()
  if not HasRemotePearlShard()
      or main_id == nil
      or not core.SendDataToShard(RPC_REQUEST, main_id, {}) then
    core.Announce(S.pearl_not_found)
  end
end

local function AnnouncePearlStatusFromChat()
  local message = TryBuildLocalStatusMessage()
  if message ~= nil then
    if not BroadcastStatus(message) then
      core.Announce(S.pearl_not_found)
    end
    return
  end
  RequestRemoteStatus()
end

local function GetPersistedFriendAnnounceCycle()
  if last_friend_announce_cycle ~= nil then
    return last_friend_announce_cycle
  end
  local state = GetWorldStateComponent()
  if state ~= nil then
    last_friend_announce_cycle = state:Get(FRIEND_ANNOUNCE_CYCLE_KEY)
  end
  return last_friend_announce_cycle
end

local function SetPersistedFriendAnnounceCycle(cycles)
  last_friend_announce_cycle = cycles
  local state = GetWorldStateComponent()
  if state ~= nil then
    state:Set(FRIEND_ANNOUNCE_CYCLE_KEY, cycles)
  end
end

local function OnFriendLevelChanged(inst)
  local friendlevels = inst.components ~= nil and inst.components.friendlevels or nil
  if friendlevels == nil then
    return
  end
  local level = friendlevels:GetLevel() or 0
  local level_previous = inst._broadcasts_pearl_level
  if level_previous ~= nil and level > level_previous then
    local cycles = TheWorld.state ~= nil and TheWorld.state.cycles or nil
    if type(cycles) == "number" and GetPersistedFriendAnnounceCycle() ~= cycles then
      local message = TryBuildLocalStatusMessage()
      if message ~= nil and BroadcastStatus(message) then
        SetPersistedFriendAnnounceCycle(cycles)
      end
    end
  end
  inst._broadcasts_pearl_level = level
end

local function WatchPearl(inst)
  if not core.World.IsServerSide() then
    return
  end
  --- 延后到 OnLoad 之后再挂监听，避免读档时 friend_level_changed 误公告
  inst:DoTaskInTime(0, core.Wrap(function()
    if not inst:IsValid() then
      return
    end
    local friendlevels = inst.components ~= nil and inst.components.friendlevels or nil
    if friendlevels == nil then
      return
    end
    inst._broadcasts_pearl_level = friendlevels:GetLevel() or 0
    inst:ListenForEvent("friend_level_changed", core.Wrap(OnFriendLevelChanged))
  end))
end

AddPrefabPostInit("hermitcrab", WatchPearl)

core.ListenSay("server", function(say)
  if say.whisper or say.isemote then
    return
  end
  if core.UpperString(core.TrimString(say.message)) == CHAT_TRIGGER then
    AnnouncePearlStatusFromChat()
  end
end)

--- 主分片：收到查询后本地找 Pearl 并 Announce（全服可见）
core.ReceiveDataFromShard(RPC_REQUEST, function(from_shard, fields)
  local message = TryBuildLocalStatusMessage()
  if message ~= nil then
    BroadcastStatus(message)
  else
    core.Announce(S.pearl_not_found)
  end
end)
