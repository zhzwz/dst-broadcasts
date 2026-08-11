--- 模组持久化 State 组件入口（世界级 / 玩家级）。

local WORLD_STATE = "world_state_3774915634"
local PLAYER_STATE = "player_state_3774915634"

--- Get / Set + 随实体 OnSave/OnLoad；世界与玩家组件 API 相同。
--- @class StateComponent
--- @field inst Entity
--- @field data table
--- @field Get fun(self: StateComponent, key: string, default: any): any
--- @field Set fun(self: StateComponent, key: string, value: any)

--- 取世界级持久化组件；未挂载时为 nil。
--- @param world Entity|nil 默认 `TheWorld`（可传本分片 world）
--- @return StateComponent|nil
GetWorldStateComponent = function(world)
  world = world or TheWorld
  if world == nil or world.components == nil then
    return nil
  end
  return world.components[WORLD_STATE]
end

--- 取玩家级持久化组件；未挂载时为 nil。
--- @param player Entity|nil
--- @return StateComponent|nil
GetPlayerStateComponent = function(player)
  if player == nil or player.components == nil then
    return nil
  end
  return player.components[PLAYER_STATE]
end
