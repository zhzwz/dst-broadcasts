--- 模组持久化 State 组件入口（世界级 / 玩家级）。
--- 未挂载会 error：只有已包好的路径才可调用（如 core.Wrap / core.Call / DST_HOOK）。

local WORLD_STATE = "world_state_3774915634"
local PLAYER_STATE = "player_state_3774915634"

--- Get / Set + 随实体 OnSave/OnLoad；世界与玩家组件 API 相同。
--- @class StateComponent
--- @field inst Entity
--- @field data table
--- @field Get fun(self: StateComponent, key: string, default: any): any
--- @field Set fun(self: StateComponent, key: string, value: any)

--- 取世界级持久化组件；未挂载则 error（仅已包好的路径可调用）。
--- @param world Entity|nil 默认 `TheWorld`（可传本分片 world）
--- @return StateComponent
GetWorldStateComponent = function(world)
  world = world or TheWorld
  local state = world ~= nil and world.components ~= nil and world.components[WORLD_STATE] or nil
  if state == nil then
    error(WORLD_STATE .. " missing")
  end
  return state
end

--- 取玩家级持久化组件；未挂载则 error（仅已包好的路径可调用）。
--- @param player Entity
--- @return StateComponent
GetPlayerStateComponent = function(player)
  local state = player ~= nil and player.components ~= nil and player.components[PLAYER_STATE] or nil
  if state == nil then
    error(PLAYER_STATE .. " missing")
  end
  return state
end
