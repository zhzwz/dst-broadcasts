--[[
  Pearl（寄居蟹隐士）好感与待办任务。

  触发：
  - 公频聊天精确发送 pearl（含跨分片：洞穴可查地表状态）
  - 好感等级提升时自动播报（每个游戏日最多一次）
]]

local S = BROADCASTS_STRINGS
local C = BROADCASTS_PEARL
local TASK_IDS = BROADCASTS_PEARL_TASKS

local RPC_NS = modname
local RPC_MAGIC = "dst_broadcasts_pearl_v1"
local RPC_REQUEST = "PearlStatusRequest"
local RPC_ANNOUNCE = "PearlStatusAnnounce"
local RPC_QUERY_RESULT = "PearlStatusQueryResult"
-- 按字节计；中文待办较长时需留余量
local STATUS_MESSAGE_MAX_LEN = 2048

local CHAT_TRIGGERS = {
  pearl = true,
}

-- userid -> { t = GetTime(), fail = bool }
local last_announce_by_user = {}
local FRIEND_ANNOUNCE_CYCLE_KEY = "pearl_friend_announce_cycle"
local last_friend_announce_cycle = nil

-- 跨分片查询：多人可共用同一次请求
-- 查询结果走独立 RPC，与好感同步播报分离，避免 token 丢失时串通道
local remote_waiters = {}
local remote_request_inflight = false
local remote_request_token = 0
local remote_expect_token = 0

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

  -- Pearl 只在地表；洞穴等次级分片不要扫 Ents
  if TheShard ~= nil and TheShard:IsSecondary() then
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

local function IsTrustedRpc(magic)
  return magic == RPC_MAGIC
end

-- 结构校验：允许跨分片语言配置不一致（均以 [Name]x/y… 形式）
local function IsValidStatusMessage(message)
  if type(message) ~= "string" or message == "" or #message > STATUS_MESSAGE_MAX_LEN then
    return false
  end
  if string.find(message, "[\r\n%z]", 1) ~= nil then
    return false
  end
  if string.find(message, "^%[[^%]]+%]") ~= 1 then
    return false
  end
  if string.find(message, "%d+/%d+") == nil then
    return false
  end
  return true
end

local function CooldownKey(userid)
  if userid == nil or userid == "" then
    return "_"
  end
  return userid
end

local function IsOnCooldown(userid)
  local entry = last_announce_by_user[CooldownKey(userid)]
  if entry == nil or type(entry.t) ~= "number" then
    return false
  end
  local cd = entry.fail and C.FAIL_COOLDOWN_SECONDS or C.COOLDOWN_SECONDS
  return (GetTime() - entry.t) < cd
end

local function MarkCooldown(userid, is_fail)
  last_announce_by_user[CooldownKey(userid)] = {
    t = GetTime(),
    fail = is_fail and true or false,
  }
end

local function MarkWaitersCooldown(is_fail)
  for key, userid in pairs(remote_waiters) do
    MarkCooldown(userid, is_fail)
    remote_waiters[key] = nil
  end
end

local function CancelRemoteRequest()
  remote_request_inflight = false
  remote_expect_token = 0
  remote_request_token = remote_request_token + 1
end

local function HasRemotePearlShard()
  -- Pearl 在地表；通常为 master。本分片已是 master 时不必再问其它分片。
  if TheShard ~= nil and SHARDID ~= nil and SHARDID.MASTER ~= nil then
    if tostring(TheShard:GetShardId()) == tostring(SHARDID.MASTER) then
      return false
    end
    if Shard_IsWorldAvailable ~= nil then
      return Shard_IsWorldAvailable(SHARDID.MASTER)
    end
  end
  -- ShardList 只含远程已连接分片
  return ShardList ~= nil and next(ShardList) ~= nil
end

local function CanSendShardRpc()
  return GetShardModRPC ~= nil and SendModRPCToShard ~= nil
end

-- 普通全分片播报（聊天本分片命中、好感同步）
-- @return boolean 是否已播报
local function BroadcastStatus(message)
  if not IsValidStatusMessage(message) then
    return false
  end
  mod.Announce(message)
  if CanSendShardRpc() then
    SendModRPCToShard(GetShardModRPC(RPC_NS, RPC_ANNOUNCE), nil, RPC_MAGIC, message)
  end
  return true
end

-- 跨分片查询的回复（独立 RPC，不与普通播报混用）
-- @return boolean 是否已播报
local function BroadcastQueryResult(message, query_token)
  if not IsValidStatusMessage(message) then
    return false
  end
  mod.Announce(message)
  if CanSendShardRpc() then
    SendModRPCToShard(GetShardModRPC(RPC_NS, RPC_QUERY_RESULT), nil, RPC_MAGIC, message, query_token or 0)
  end
  return true
end

local function FinishRemoteSuccess(message)
  CancelRemoteRequest()
  if IsValidStatusMessage(message) then
    MarkWaitersCooldown(false)
    mod.Announce(message)
  else
    MarkWaitersCooldown(true)
  end
end

local function FinishRemoteNotFound()
  MarkWaitersCooldown(true)
  CancelRemoteRequest()
  mod.Announce(S.pearl_not_found)
end

local function RequestRemoteStatus(userid)
  remote_waiters[CooldownKey(userid)] = userid

  if remote_request_inflight then
    return
  end

  if not CanSendShardRpc() or not HasRemotePearlShard() or TheWorld == nil then
    FinishRemoteNotFound()
    return
  end

  remote_request_inflight = true
  remote_request_token = remote_request_token + 1
  local token = remote_request_token
  remote_expect_token = token

  local target = (SHARDID ~= nil and SHARDID.MASTER) or nil
  SendModRPCToShard(GetShardModRPC(RPC_NS, RPC_REQUEST), target, RPC_MAGIC, token)

  TheWorld:DoTaskInTime(C.SHARD_TIMEOUT_SECONDS, function()
    if token ~= remote_expect_token or not remote_request_inflight then
      return
    end
    FinishRemoteNotFound()
  end)
end

local function AnnouncePearlStatusFromChat(userid)
  if IsOnCooldown(userid) then
    return
  end

  local message = TryBuildLocalStatusMessage()
  if message ~= nil then
    if BroadcastStatus(message) then
      MarkCooldown(userid, false)
    else
      MarkCooldown(userid, true)
    end
    return
  end
  RequestRemoteStatus(userid)
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
  if not TheWorld.ismastersim then
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
    AnnouncePearlStatusFromChat(userid)
  end
end

local old_networking_say = Networking_Say
Networking_Say = function(guid, userid, name, prefab, message, colour, whisper, isemote, user_vanity)
  if TheWorld ~= nil and TheWorld.ismastersim then
    mod.Call("pearl_status_say", OnChatSay, guid, userid, name, prefab, message, colour, whisper, isemote, user_vanity)
  end
  if old_networking_say ~= nil then
    return old_networking_say(guid, userid, name, prefab, message, colour, whisper, isemote, user_vanity)
  end
end

local function IsSelfShard(from_shard)
  return TheShard ~= nil and tostring(TheShard:GetShardId()) == tostring(from_shard)
end

-- 好感同步 / 本分片命中后的跨片同步
AddShardModRPCHandler(RPC_NS, RPC_ANNOUNCE, function(from_shard, magic, message)
  if IsSelfShard(from_shard) or not IsTrustedRpc(magic) then
    return
  end
  if IsValidStatusMessage(message) then
    mod.Announce(message)
  end
end)

-- 仅用于跨分片查询回复；超时后的迟到包因 inflight 已清而丢弃
AddShardModRPCHandler(RPC_NS, RPC_QUERY_RESULT, function(from_shard, magic, message, query_token)
  if IsSelfShard(from_shard) or not IsTrustedRpc(magic) then
    return
  end
  if not IsValidStatusMessage(message) or not remote_request_inflight then
    return
  end

  local token = tonumber(query_token) or 0
  if token ~= 0 and token == remote_expect_token then
    FinishRemoteSuccess(message)
  end
end)

AddShardModRPCHandler(RPC_NS, RPC_REQUEST, mod.Wrap("pearl_rpc_request", function(from_shard, magic, query_token)
  if IsSelfShard(from_shard) or not IsTrustedRpc(magic) then
    return
  end
  local message = TryBuildLocalStatusMessage()
  if message ~= nil then
    BroadcastQueryResult(message, tonumber(query_token) or 0)
  end
end))
