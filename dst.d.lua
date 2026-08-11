---@meta _

--- DST 官方 API 类型桩（仅供 LuaLS，无运行时逻辑）。
--- 内容一律以游戏官方脚本为准（见 AGENTS.md 中的 scripts.zip 路径）；
--- 禁止为迁就本模组写法而私自增删、改名或改签名。

---------------------------------------------------------------------------
--- 模组加载
---------------------------------------------------------------------------

--- @param path string
function modimport(path) end

---------------------------------------------------------------------------
--- PostInit
---------------------------------------------------------------------------

--- 模拟（Sim）就绪后回调一次；世界、`TheWorld` 等已可用。
--- @param fn fun() 回调；若注册时 Sim 已就绪则不会再执行（需自行立刻跑逻辑）
function AddSimPostInit(fn) end

--- 指定组件构造完成后回调，用于扩展或挂钩原版组件。
--- @param classname string 组件名（如 `"luckuser"`、`"kramped"`）
--- @param fn fun(self: table) 回调；`self` 为该组件实例
function AddComponentPostInit(classname, fn) end

--- 指定 prefab 构造完成后回调。
--- @param prefab string
--- @param fn fun(inst: Entity)
function AddPrefabPostInit(prefab, fn) end

--- 玩家 prefab 构造完成后回调。
--- @param fn fun(player: Entity)
function AddPlayerPostInit(fn) end

---------------------------------------------------------------------------
--- 全局
---------------------------------------------------------------------------

--- 世界正在读档 / 填充实体时为 `true`；加载期的数值变化通常应忽略，避免误公告。
--- @type boolean
POPULATING = false

--- @type Entity[]|nil
AllPlayers = nil

--- @type World
TheWorld = nil

---------------------------------------------------------------------------
--- 实体与组件
---------------------------------------------------------------------------

--- @class HealthComponent
--- @field currenthealth number|nil
--- @field minhealth number|nil
--- @field IsDead fun(self: HealthComponent): boolean

--- @class StackableComponent
--- @field StackSize fun(self: StackableComponent): number

--- @class InventoryitemComponent
--- @field GetGrandOwner fun(self: InventoryitemComponent): Entity|nil

--- @class TalkerComponent
--- @field Say fun(self: TalkerComponent, script: string|table, time: number|nil, noanim: boolean|nil, force: boolean|nil, nobroadcast: boolean|nil, ...: any)

--- 若干常见组件的字段类型（`Entity.components` 仍为动态表）。
--- @class EntityComponents
--- @field health HealthComponent|nil
--- @field stackable StackableComponent|nil
--- @field inventoryitem InventoryitemComponent|nil
--- @field talker TalkerComponent|nil

--- @class PeriodicTask
--- @field Cancel fun(self: PeriodicTask)

--- @class Entity
--- @field prefab string|nil
--- @field components table<string, any>|nil
--- @field GUID any
--- @field userid string|nil
--- @field playercolour number[]|nil
--- @field ismastersim boolean|nil
--- @field IsValid fun(self: Entity): boolean
--- @field HasTag fun(self: Entity, tag: string): boolean
--- @field GetDisplayName fun(self: Entity): string
--- @field AddComponent fun(self: Entity, name: string): any
--- @field DoTaskInTime fun(self: Entity, time: number, fn: function, ...: any): PeriodicTask
--- @field DoPeriodicTask fun(self: Entity, time: number, fn: function, ...: any): PeriodicTask
--- @field ListenForEvent fun(self: Entity, event: string, fn: function, ...: any)
--- @field WatchWorldState fun(self: Entity, key: string, fn: function)
--- @field entity any

---------------------------------------------------------------------------
--- 世界 / 天气
---------------------------------------------------------------------------

--- 官方风暴类型枚举（`constants.lua`）；`ms_stormchanged` 的 `stormtype` 用此值。
--- @class StormTypes
--- @field NONE integer
--- @field SANDSTORM integer
--- @field MOONSTORM integer

--- @type StormTypes
STORM_TYPES = {
  NONE = 0,
  SANDSTORM = 1,
  MOONSTORM = 2,
}

--- `TheWorld` 事件 `ms_stormchanged` 的 data。
--- @class MsStormChangedData
--- @field stormtype integer
--- @field setting boolean

--- TheWorld.state.precipitation
--- @alias PrecipitationType "none" | "rain" | "snow" | "acidrain" | "lunarhail"

--- TheWorld.state（worldstate.data 投影）
--- @class WorldState
--- @field precipitation PrecipitationType|nil
--- @field precipitationrate number|nil
--- @field cycles number|nil
--- @field season string|nil

--- TheWorld
--- @class World : Entity
--- @field state WorldState|nil
--- @field net Entity|nil

---------------------------------------------------------------------------
--- 分片 RPC
---------------------------------------------------------------------------

--- GetShardModRPC 返回的 RPC 句柄
--- @class ShardModRPC
--- @field namespace string
--- @field id any

--- @param namespace string
--- @param name string
--- @return ShardModRPC|nil
function GetShardModRPC(namespace, name) end

--- @param id_table ShardModRPC
--- @param target string|number|table|nil nil=所有远程分片；shard id；或 id 列表
--- @param data string 单一字符串载荷（引擎会在 handler 前再插入 from_shard）
function SendModRPCToShard(id_table, target, data) end

--- @param namespace string
--- @param name string
--- @param handler fun(from_shard: string|number, data: string)
function AddShardModRPCHandler(namespace, name, handler) end

---------------------------------------------------------------------------
--- 客户端 RPC
---------------------------------------------------------------------------

--- @class ClientModRPC
--- @field namespace string
--- @field id any

--- @param namespace string
--- @param name string
--- @return ClientModRPC|nil
function GetClientModRPC(namespace, name) end

--- @param id_table ClientModRPC
--- @param clients string|string[]|nil nil=本分片所有客户端；userid；或 userid 列表
--- @param ... any
function SendModRPCToClient(id_table, clients, ...) end

--- @param namespace string
--- @param name string
--- @param handler function
function AddClientModRPCHandler(namespace, name, handler) end
