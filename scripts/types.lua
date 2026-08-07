--- 类型桩（仅供注解 / LuaLS，无运行时逻辑）。
--- 顺序：游戏 / 引擎 API → 模组内部类型。

---------------------------------------------------------------------------
--- 游戏 / 引擎 API
---------------------------------------------------------------------------

--- @param path string
function modimport(path) end

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

--- @class EntityComponents
--- @field health HealthComponent|nil
--- @field stackable StackableComponent|nil
--- @field inventoryitem InventoryitemComponent|nil
--- @field talker TalkerComponent|nil

--- @class PeriodicTask
--- @field Cancel fun(self: PeriodicTask)

--- @class Entity
--- @field prefab string|nil
--- @field components EntityComponents|nil
--- @field GUID any
--- @field userid string|nil
--- @field playercolour number[]|nil
--- @field ismastersim boolean|nil
--- @field IsValid fun(self: Entity): boolean
--- @field HasTag fun(self: Entity, tag: string): boolean
--- @field GetDisplayName fun(self: Entity): string
--- @field DoTaskInTime fun(self: Entity, time: number, fn: function, ...: any): PeriodicTask
--- @field DoPeriodicTask fun(self: Entity, time: number, fn: function, ...: any): PeriodicTask
--- @field ListenForEvent fun(self: Entity, event: string, fn: function, ...: any)
--- @field entity any

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

--- @type Entity[]|nil
AllPlayers = nil

---------------------------------------------------------------------------
--- 模组内部类型
---------------------------------------------------------------------------

--- 天气播报降水键（互斥；无降水为 nil）
--- @alias PrecipitationKey "acidrain" | "lunarhail" | "rain_light" | "rain_normal" | "rain_heavy" | "rain_storm" | "snow_light" | "snow_normal" | "snow_heavy" | "snow_storm"

--- 天气播报键（与 i18n.weather 标签键对应）
--- @alias WeatherKey "sunny" | PrecipitationKey | "sandstorm" | "moonstorm"
