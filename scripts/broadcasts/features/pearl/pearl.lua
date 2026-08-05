--[[
  Pearl（寄居蟹隐士）好感与待办任务。

  触发：
  - 公频聊天精确发送 pearl（含跨分片：洞穴可查地表状态；不限制触发频率）
  - 好感等级提升时自动播报（每个游戏日最多一次）
]]

local S = i18n
local TASK_IDS = BROADCASTS_PEARL_TASKS

local RPC_REQUEST = "PearlStatusRequest"
-- 按字节计；中文待办较长时需留余量
local STATUS_MESSAGE_MAX_LEN = 2048

local CHAT_TRIGGERS = {
  pearl = true,
}

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
    -- 管理器未挂上实例时回退扫描，避免误报未找到
  end

  -- Pearl 只在主分片（地表）；非主分片不要扫 Ents
  local self_id = mod.Shard.GetSelfId()
  if self_id == nil then
    return nil
  end
  if not mod.Shard.IsMain(self_id) then
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

-- 仅当本分片存在 Pearl 时返回文案；否则返回 nil
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
    message = message .. string.format(S.pearl_tasks_pending, table.concat(pending, S.list_separator))
  else
    message = message .. S.pearl_tasks_done
  end
  return message
end

-- 结构校验：允许跨分片语言配置不一致（含 x/y 好感格式即可）
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
  -- Pearl 在地表；通常为 master。本分片已是主分片时不必再问其它分片。
  local self_id = mod.Shard.GetSelfId()
  if self_id ~= nil and mod.Shard.IsMain(self_id) then
    return false
  end
  local main_id = mod.Shard.GetMainId()
  if main_id ~= nil and type(Shard_IsWorldAvailable) == "function" then
    return Shard_IsWorldAvailable(main_id)
  end
  return mod.Shard.HasRemote()
end

-- TheNet:Announce 全服可见，任一主控分片播一次即可
local function BroadcastStatus(message)
  if not IsValidStatusMessage(message) then
    return false
  end
  mod.Announce(message)
  return true
end

-- 洞穴：向主分片要状态；文案由 Master 直接 Announce（不回传、无 token）
local function RequestRemoteStatus()
  if not HasRemotePearlShard() or not mod.Shard.SendToMain(RPC_REQUEST, {}) then
    mod.Announce(S.pearl_not_found)
  end
end

local function AnnouncePearlStatusFromChat()
  local message = TryBuildLocalStatusMessage()
  if message ~= nil then
    if not BroadcastStatus(message) then
      mod.Announce(S.pearl_not_found)
    end
    return
  end
  RequestRemoteStatus()
end

local function GetPersistedFriendAnnounceCycle()
  if last_friend_announce_cycle ~= nil then
    return last_friend_announce_cycle
  end
  local state = TheWorld ~= nil and TheWorld.components ~= nil and TheWorld.components.state_3774915634 or nil
  if state ~= nil then
    last_friend_announce_cycle = state:Get(FRIEND_ANNOUNCE_CYCLE_KEY)
  end
  return last_friend_announce_cycle
end

local function SetPersistedFriendAnnounceCycle(cycles)
  last_friend_announce_cycle = cycles
  local state = TheWorld ~= nil and TheWorld.components ~= nil and TheWorld.components.state_3774915634 or nil
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
  local prev = inst._broadcasts_pearl_level
  inst._broadcasts_pearl_level = level
  if prev == nil or level <= prev then
    return
  end

  local cycles = TheWorld.state ~= nil and TheWorld.state.cycles or nil
  if type(cycles) ~= "number" then
    return
  end
  if GetPersistedFriendAnnounceCycle() == cycles then
    return
  end

  local message = TryBuildLocalStatusMessage()
  if message ~= nil and BroadcastStatus(message) then
    SetPersistedFriendAnnounceCycle(cycles)
  end
end

local function WatchPearl(inst)
  if not mod.World.IsServer() then
    return
  end
  -- 延后到 OnLoad 之后再挂监听，避免读档时 friend_level_changed 误播报
  inst:DoTaskInTime(0, function()
    if not inst:IsValid() then
      return
    end
    local friendlevels = inst.components ~= nil and inst.components.friendlevels or nil
    if friendlevels == nil then
      return
    end
    inst._broadcasts_pearl_level = friendlevels:GetLevel() or 0
    inst:ListenForEvent("friend_level_changed", mod.Wrap("pearl_level_changed", OnFriendLevelChanged))
  end)
end

AddPrefabPostInit("hermitcrab", WatchPearl)

local function NormalizeChatMessage(message)
  if type(message) ~= "string" then
    return nil
  end
  local trimmed = message:match("^%s*(.-)%s*$") or message
  if trimmed == "" then
    return nil
  end
  local lower = string.lower(trimmed)
  if CHAT_TRIGGERS[lower] then
    return lower
  end
  if CHAT_TRIGGERS[trimmed] then
    return trimmed
  end
  return nil
end

local function OnChatSay(guid, userid, name, prefab, message, colour, whisper, isemote, user_vanity)
  if whisper or isemote then
    return
  end
  if NormalizeChatMessage(message) ~= nil then
    AnnouncePearlStatusFromChat()
  end
end

local old_networking_say = Networking_Say
Networking_Say = function(guid, userid, name, prefab, message, colour, whisper, isemote, user_vanity)
  if mod.World.IsServer() then
    mod.Call("pearl_status_say", OnChatSay, guid, userid, name, prefab, message, colour, whisper, isemote, user_vanity)
  end
  if old_networking_say ~= nil then
    return old_networking_say(guid, userid, name, prefab, message, colour, whisper, isemote, user_vanity)
  end
end

-- 主分片：收到查询后本地找 Pearl 并 Announce（全服可见）
mod.Shard.On(RPC_REQUEST, function(from_shard, fields)
  local message = TryBuildLocalStatusMessage()
  if message ~= nil then
    BroadcastStatus(message)
  else
    mod.Announce(S.pearl_not_found)
  end
end)
