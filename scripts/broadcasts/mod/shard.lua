local NAMESPACE = mod.CONSTANTS.RPC_NAMESPACE

--- 本分片 id
--- @return string|number|nil
local function GetSelfId()
  if TheShard == nil or type(TheShard.GetShardId) ~= "function" then
    return nil
  end
  return mod.Call("mod.Shard.GetSelfId", TheShard.GetShardId, TheShard)
end

--- 判断是否当前分片
--- @param shard_id string|number|nil
--- @return boolean
local function IsSelf(shard_id)
  if shard_id == nil then
    return false
  end
  local id = GetSelfId()
  return id ~= nil and tostring(id) == tostring(shard_id)
end

--- 是否有已连接的远程分片
--- @return boolean
local function HasRemote()
  return ShardList ~= nil and next(ShardList) ~= nil
end

--- 主分片 id（通常为地表）
--- @return string|number|nil
local function GetMainId()
  return SHARDID ~= nil and SHARDID.MASTER or nil
end

--- 判断是否主分片 id
--- @param shard_id string|number|nil
--- @return boolean
local function IsMain(shard_id)
  if shard_id == nil then
    return false
  end
  local main_id = GetMainId()
  return main_id ~= nil and tostring(main_id) == tostring(shard_id)
end

local function SplitParts(data)
  --- @type string[]
  local parts = {}
  local start = 1
  while true do
    local i = string.find(data, "\0", start, true)
    if i == nil then
      table.insert(parts, string.sub(data, start))
      break
    end
    table.insert(parts, string.sub(data, start, i - 1))
    start = i + 1
  end
  return parts
end

--- 是否为从 1 起连续的数组（空表视为空数组）
--- @param t table
--- @return boolean
local function IsArray(t)
  local count = 0
  for k in pairs(t) do
    if type(k) ~= "number" or k < 1 or k ~= math.floor(k) then
      return false
    end
    count = count + 1
  end
  for i = 1, count do
    if t[i] == nil then
      return false
    end
  end
  return true
end

local function FieldToString(v)
  if v == nil then
    return ""
  end
  if type(v) == "boolean" then
    return v and "1" or "0"
  end
  if type(v) == "table" then
    if not IsArray(v) then
      return nil
    end
    --- @type string[]
    local items = {}
    for i, item in ipairs(v) do
      local s = tostring(item)
      if string.find(s, "[,\0]", 1) ~= nil then
        return nil
      end
      items[i] = s
    end
    return table.concat(items, ",")
  end
  local s = tostring(v)
  if string.find(s, "%z", 1) ~= nil then
    return nil
  end
  return s
end

--- @param fields table<string, string|number|boolean|string[]|nil>
--- @return string|nil
local function Pack(fields)
  if type(fields) ~= "table" then
    return nil
  end
  --- @type string[]
  local keys = {}
  for k in pairs(fields) do
    if type(k) ~= "string" or k == "" or string.find(k, "%z", 1) ~= nil then
      return nil
    end
    table.insert(keys, k)
  end
  table.sort(keys)

  --- @type string[]
  local parts = {}
  for _, k in ipairs(keys) do
    local s = FieldToString(fields[k])
    if s == nil then
      return nil
    end
    table.insert(parts, k)
    table.insert(parts, s)
  end
  return table.concat(parts, "\0")
end

--- @param data string
--- @return table<string, string>|nil
local function Unpack(data)
  if type(data) ~= "string" then
    return nil
  end
  if data == "" then
    return {}
  end
  local parts = SplitParts(data)
  if #parts % 2 ~= 0 then
    return nil
  end
  --- @type table<string, string>
  local fields = {}
  for i = 1, #parts, 2 do
    fields[parts[i]] = parts[i + 1]
  end
  return fields
end

--- 发送字段表（内部自动打包）；失败返回 false
--- @param name string
--- @param target string|number|nil nil 表示所有远程分片（仅在明确需要广播时传入）
--- @param fields table<string, string|number|boolean|string[]|nil>
--- @return boolean
local function Send(name, target, fields)
  local data = Pack(fields)
  if data == nil then
    return false
  end
  local rpc = mod.Call("mod.Shard.Send.get", GetShardModRPC, NAMESPACE, name)
  if rpc == nil then
    return false
  end
  local ok, err = pcall(SendModRPCToShard, rpc, target, data)
  if not ok then
    mod.Print("mod.Shard.Send", err)
    return false
  end
  return true
end

--- 发往主分片；无主分片 id 时返回 false（不会把 nil target 当成广播）
--- @param name string
--- @param fields table<string, string|number|boolean|string[]|nil>
--- @return boolean
local function SendToMain(name, fields)
  local main_id = GetMainId()
  if main_id == nil then
    return false
  end
  return Send(name, main_id, fields)
end

--- 注册 handler；内部自动解包，回调拿到字段表（值均为 string）
--- @param name string
--- @param handler fun(from_shard: string|number, fields: table<string, string>)
local function On(name, handler)
  AddShardModRPCHandler(NAMESPACE, name, function(from_shard, data)
    --- 无法识别本分片时丢弃，避免在身份不明时误处理
    if GetSelfId() == nil or IsSelf(from_shard) then
      return
    end
    local fields = Unpack(data)
    if fields == nil then
      return
    end
    mod.Call(name, handler, from_shard, fields)
  end)
end

--- @class BroadcastsShardApi
--- @field GetSelfId fun(): string|number|nil
--- @field GetMainId fun(): string|number|nil
--- @field IsSelf fun(shard_id: string|number|nil): boolean
--- @field IsMain fun(shard_id: string|number|nil): boolean
--- @field HasRemote fun(): boolean
--- @field Send fun(name: string, target: string|number|nil, fields: table): boolean
--- @field SendToMain fun(name: string, fields: table): boolean
--- @field On fun(name: string, handler: fun(from_shard: string|number, fields: table<string, string>))

--- @type BroadcastsShardApi
mod.Shard = {
  GetSelfId = GetSelfId,
  GetMainId = GetMainId,
  IsSelf = IsSelf,
  IsMain = IsMain,
  HasRemote = HasRemote,
  Send = Send,
  SendToMain = SendToMain,
  On = On,
}

--- mod.Shard.Send("NAME", target, { a = 1 })
--- mod.Shard.SendToMain("NAME", { a = 1 })
--- mod.Shard.On("NAME", function(from_shard, fields) ... end)
