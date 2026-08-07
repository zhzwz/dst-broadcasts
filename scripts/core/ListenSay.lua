--- core.ListenSay 回调参数（与 Networking_Say 字段对应）。
--- guid 发言实体 GUID；userid 玩家 id；name 显示名；prefab 角色 prefab；
--- message 正文；colour 名字颜色；whisper 是否密语；isemote 是否表情；user_vanity 头像等装饰。
--- @alias ListenSayEvent { guid: string|nil, userid: string|nil, name: string|nil, prefab: string|nil, message: string|nil, colour: table|nil, whisper: boolean|nil, isemote: boolean|nil, user_vanity: any }
--- @alias ListenSaySide "server" | "client"

local server_listeners = {}
local client_listeners = {}
local hooked = false
local sim_scheduled = false

local function EnsureHooked()
  if hooked then
    return
  end
  hooked = true
  local previous_say = GLOBAL.Networking_Say
  --- 必须写 GLOBAL：模组 env 的赋值不会覆盖游戏实际调用的全局
  GLOBAL.Networking_Say = function(guid, userid, name, prefab, message, colour, whisper, isemote, user_vanity)
    local on_server = core.IsServer()
    local on_client = core.IsClient()
    local run_server = on_server and #server_listeners > 0
    local run_client = on_client and #client_listeners > 0
    if run_server or run_client then
      local say = {
        guid = guid,
        userid = userid,
        name = name,
        prefab = prefab,
        message = message,
        colour = colour,
        whisper = whisper,
        isemote = isemote,
        user_vanity = user_vanity,
      }
      if run_server then
        for i = 1, #server_listeners do
          core.Call(server_listeners[i], say)
        end
      end
      if run_client then
        for i = 1, #client_listeners do
          core.Call(client_listeners[i], say)
        end
      end
    end
    if previous_say ~= nil then
      return previous_say(guid, userid, name, prefab, message, colour, whisper, isemote, user_vanity)
    end
  end
end

local function EnsureSimScheduled()
  if sim_scheduled then
    return
  end
  sim_scheduled = true
  --- Sim 就绪后再按本侧是否有监听决定是否挂钩，避免客户端无谓改写 GLOBAL
  AddSimPostInit(core.Wrap(function()
    if (#server_listeners > 0 and core.IsServer()) or (#client_listeners > 0 and core.IsClient()) then
      EnsureHooked()
    end
  end))
end

--- 监听玩家聊天（挂钩 GLOBAL.Networking_Say）。
--- side 为 "server" 时仅主机回调并挂钩；"client" 时仅客户端。
--- @param side ListenSaySide
--- @param fn fun(say: ListenSayEvent)
core.ListenSay = function(side, fn)
  if type(fn) ~= "function" then
    return
  end
  if side == "server" then
    table.insert(server_listeners, fn)
  elseif side == "client" then
    table.insert(client_listeners, fn)
  else
    return
  end
  EnsureSimScheduled()
end
