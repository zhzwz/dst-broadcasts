--- DST 类型桩（仅供注解 / LuaLS，无运行时逻辑）

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

--- @class Entity
--- @field prefab string|nil
--- @field components EntityComponents|nil
--- @field GUID any
--- @field ismastersim boolean|nil
--- @field IsValid fun(self: Entity): boolean
--- @field HasTag fun(self: Entity, tag: string): boolean
--- @field GetDisplayName fun(self: Entity): string

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

--- 降水键（互斥；无降水为 nil）
--- @alias PrecipitationKey "acidrain" | "lunarhail" | "rain_light" | "rain_normal" | "rain_heavy" | "rain_storm" | "snow_light" | "snow_normal" | "snow_heavy" | "snow_storm"
--- 天气键（与 i18n.weather 标签键对应；另含 report/separator 文案键）
--- @alias WeatherKey "sunny" | PrecipitationKey | "sandstorm" | "moonstorm"
