--- 玩家淘气值（Krampus）
--- 无阈值，数值变动即公告；原版无公开事件，每 INTERVAL 秒轮询 kramped 私有表 `_activeplayers`。

local INTERVAL = 5

--- 从 kramped.OnUpdate 上值取出私有表 `_activeplayers`。
local function GetActivePlayers(kramped)
  if type(kramped.OnUpdate) ~= "function" then
    core.Print("krampus: OnUpdate is not a function")
    return nil
  end

  local i = 1
  while true do
    local upname, value = debug.getupvalue(kramped.OnUpdate, i)
    if upname == nil then
      core.Print("krampus: _activeplayers upvalue not found")
      return nil
    end
    if upname == "_activeplayers" then
      return value
    end
    i = i + 1
  end
end

local function Announce(player, actions, threshold)
  -- 取显示名；拿不到则不公告
  local name = core.GetDisplayName(player)
  if name == nil then return end

  -- 玩家
  if not player:HasTag("player") then return end
  -- 非幽灵
  if player:HasTag("playerghost") then return end

  -- 有阈值时公告当前/阈值，否则只公告当前值
  if threshold ~= nil then
    core.Announce(string.format("[%s] KRAMPUS: %s/%s", name, actions, threshold))
    return
  end
  core.Announce(string.format("[%s] KRAMPUS: %s", name, actions))
end

AddComponentPostInit("kramped", core.Wrap(function(self)
  -- 仅服务端
  if not core.IsServer() then return end

  local activeplayers = GetActivePlayers(self)
  if activeplayers == nil then return end

  -- 弱键缓存：上次淘气值；玩家实体回收后自动失效
  local actions_cache = setmetatable({}, { __mode = "k" })

  -- 每 INTERVAL 秒轮询淘气值变化
  core.SetInterval(self.inst, function()
    -- 读档填充期不公告
    if POPULATING then return end

    for player, data in pairs(activeplayers) do
      local actions = data.actions or 0
      local cached = actions_cache[player]
      -- 有变化则更新缓存
      if cached ~= actions then
        actions_cache[player] = actions
        -- 首次同步（cached 为 nil）不公告，之后变动才公告
        if cached ~= nil then
          core.Call(Announce, player, actions, data.threshold)
        end
      end
    end
  end, INTERVAL)
end))
