local S = BROADCASTS_STRINGS
local Safe = BROADCASTS_SAFE

local ACTIVE_KEY = "frog_rain_active"
local COUNT_KEY = "frog_rain_count"
local ENABLED = GetModConfigData("frog_rain_enabled")

local function GetState(world)
    return world.components.state_3774915634
end

-- 与原版 frograin.ToggleUpdate 的开启条件一致。
local function IsFrogRainSpawning(world)
    local state = world.state
    return state.isspring
        and state.israining
        and state.precipitationrate > TUNING.FROG_RAIN_PRECIPITATION
        and state.moistureceil > TUNING.FROG_RAIN_MOISTURE
end

local function ClearFrogRainState(world)
    local state = GetState(world)
    if state == nil then
        return
    end
    state:Set(ACTIVE_KEY, nil)
    state:Set(COUNT_KEY, nil)
end

local function CountFrog(world)
    local state = GetState(world)
    if state == nil then
        return
    end

    state:Set(ACTIVE_KEY, true)
    state:Increment(COUNT_KEY)
end

local function FinishFrogRain(world)
    local state = GetState(world)
    if state == nil or not state:Get(ACTIVE_KEY, false) then
        return
    end

    local count = state:Get(COUNT_KEY, 0)
    ClearFrogRainState(world)

    if count > 0 then
        Safe.Announce(string.format(S.frog_rain_ended, count))
    end
end

if ENABLED then
    AddComponentPostInit("frograin", function(self)
        local old_start_tracking = self.StartTracking
        self.StartTracking = function(component, target)
            old_start_tracking(component, target)
            Safe.Call("frog_rain_count", CountFrog, component.inst)
        end
    end)
end

AddSimPostInit(Safe.Wrap("frog_rain_init", function()
    if not TheWorld.ismastersim or TheWorld:HasTag("cave") then
        return
    end

    -- 功能关闭时丢弃未结算计数，避免再次开启后误播报。
    if not ENABLED then
        ClearFrogRainState(TheWorld)
        return
    end

    local on_condition = Safe.Wrap("frog_rain_finished", function()
        if not IsFrogRainSpawning(TheWorld) then
            FinishFrogRain(TheWorld)
        end
    end)

    TheWorld:WatchWorldState("isspring", on_condition)
    TheWorld:WatchWorldState("israining", on_condition)
    TheWorld:WatchWorldState("precipitationrate", on_condition)
    TheWorld:WatchWorldState("moistureceil", on_condition)

    if IsFrogRainSpawning(TheWorld) then
        -- 雨仍在下：保留存档计数继续累加
        local state = GetState(TheWorld)
        if state ~= nil and state:Get(COUNT_KEY, 0) > 0 then
            state:Set(ACTIVE_KEY, true)
        end
    else
        -- 雨已停：丢弃未结算，避免读档瞬间误播旧场次
        ClearFrogRainState(TheWorld)
    end
end))
